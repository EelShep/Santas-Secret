extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd"
class_name Game

const SaveManager = preload("res://addons/MetroidvaniaSystem/Template/Scripts/SaveManager.gd")

# The game starts in this map. Note that it's scene name only, just like MetSys refers to rooms.
@export var starting_map: String
@export var custom_run: bool # For Custom Runner integration.
@export_category("Setup")
@export var level_manager: Node2D
@export var game_ui: GameUI
@export var pause_ui: PauseScreenUI
@export_category("Day Night Cycle")
@export var day_night: DayNight
@export var INITIAL_HOUR: int = 6
var day_time: float = -1.0
var curr_hour: int

var generated_rooms: Array[Vector3i]

static var instance: Game
func _init() -> void:
	if instance == null: print("Previous instance: " + str(self))
	instance = self

signal new_second(play_time: float)
#var total_play_time: float
var last_second: int = -1
var play_time: float:
	set(value):
		play_time = value
		var current_second: int = int(play_time)
		if current_second == last_second: return
		last_second = current_second
		new_second.emit(play_time)
func _process(delta: float) -> void:
	#total_play_time += delta
	play_time += delta


func _unhandled_input(event: InputEvent) -> void:
	if not OS.has_feature("editor"): return
	if event.is_action_pressed(GameConst.INPUT_SELECT):
		var music_bus: int = AudioConst.BUS_MUSIC_IDX
		AudioServer.set_bus_mute(music_bus, !AudioServer.is_bus_mute(music_bus))
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R:
				get_tree().reload_current_scene()
			KEY_0:
				Events.game_complete.emit()


func _ready() -> void:
	if !OS.has_feature("editor"):
		custom_run = false
	#NOTE Connect signals
	Events.game_ready.emit()
	Events.dialogue_toggle.connect(_on_events_dialogue_toggle)
	Events.player_died.connect(_on_events_player_died)
	Events.checkpoint_activated.connect(_on_events_checkpoint_activated)
	Events.game_complete.connect(_on_events_game_complete)
	day_night.time_tick.connect(_on_day_night_time_tick)
	#NOTE Setup MetSys & Other Dependancies
	game_ui.setup(self)

	MetSys.reset_state() # Make sure MetSys is in initial state.
	set_player($Player) # Assign player for MetSysGame.
	
	MetSys.set_save_data()
	if not FileAccess.file_exists(SaveData.SAVE_PATH):
		reset_save()
	var file = FileAccess.open(SaveData.SAVE_PATH, FileAccess.READ).get_as_text()
	if file == "": 
		reset_save()
	load_save()

	day_night.setup(self)
	
	# Initialize room when it changes.
	room_loaded.connect(init_room, CONNECT_DEFERRED)
	# Load the starting room.
	load_room(starting_map)
	
	# Find the save point and teleport the player to it, to start at the Checkpoint or PlayerSpawn.
	var start := map.get_node_or_null(^"Checkpoint")
	if custom_run or !start: start = map.get_node_or_null(^"PlayerSpawn")
	if start:
		player.position = start.position
	
	# Reset position tracking (feature specific to this project).
	reset_map_starting_coords.call_deferred()
	add_module("RoomTransitions.gd") # Add module for room transitions.


func init_room():
	MetSys.get_current_room_instance().adjust_camera_limits(%Camera2D)
	SceneTransition.fade_in()
	player.on_enter()


func handle_game_over() -> void:
	print("Game Over Man")
	get_tree().paused = true
	Events.can_pause.emit(false)
	Events.game_over.emit()
	SceneTransition.transition_ready.connect(reload_scene, CONNECT_ONE_SHOT)
	pause_ui.handle_game_over(PauseScreens.GAME_OVER_SCREEN)


func reload_scene() -> void:
	get_tree().paused = false
	Events.can_pause.emit(true)
	get_tree().reload_current_scene()

#region SAVE FUNCTIONS

func save_game():
	reset_map_starting_coords()
	var save_manager := SaveManager.new()
	save_manager.set_value(GameData.GENERATED_ROOMS, generated_rooms)
	save_manager.set_value(GameData.DAY_TIME, day_time)
	save_manager.set_value(GameData.PLAY_TIME, play_time)
	save_manager.set_value(GameData.CURR_ROOM, starting_map)
	
	save_manager.save_as_text(SaveData.SAVE_PATH)
	

func load_save() -> void:
	GameData.reset_data()
	var file = FileAccess.open(SaveData.SAVE_PATH, FileAccess.READ).get_as_text()
	if file == "": 
		reset_save()
	
	var save_manager := SaveManager.new()
	save_manager.load_from_text(SaveData.SAVE_PATH)
	
	generated_rooms = save_manager.get_value(GameData.GENERATED_ROOMS)
	day_time = save_manager.get_value(GameData.DAY_TIME)
	play_time = save_manager.get_value(GameData.PLAY_TIME)
	if not custom_run:
		var current_room = save_manager.get_value(GameData.CURR_ROOM)
		if current_room: starting_map = current_room


func reset_save() -> void:
	GameData.reset_data()
	GameData.reset_save()
	
	var save_manager := SaveManager.new()
	
	MetSys.reset_state()
	MetSys.set_save_data()
	
	generated_rooms.clear()
	save_manager.set_value(GameData.GENERATED_ROOMS, generated_rooms)
	save_manager.set_value(GameData.DAY_TIME, 0.0)
	save_manager.set_value(GameData.PLAY_TIME, 0.0)
	save_manager.set_value(GameData.CURR_ROOM, GameData.STARTING_MAP)
	
	save_manager.save_as_text(SaveData.SAVE_PATH)
#endregion
#region DAY NIGHT
const SUN_RISE_HOUR: int = 8
const NIGHT_FALL_HOUR: int = 19
const GAME_OVER_HOUR: int = 4
func _on_day_night_time_tick(day:int, hour:int, minute:int) -> void:
	if curr_hour == hour: return
	curr_hour = hour
	if curr_hour == SUN_RISE_HOUR || curr_hour == NIGHT_FALL_HOUR:
		var player: Player = Player.instance
		player.on_day_night(hour)
		game_ui.on_day_night(hour)
	if curr_hour == GAME_OVER_HOUR:
		#ALERT TESTING handle_game_over()
		game_ui.on_day_night(hour)
#endregion
#region Signal Functions
func _on_events_checkpoint_activated() -> void:
	game_ui.display_message("Checkpoint Activated")
	save_game()

func _on_events_dialogue_toggle(value: bool) -> void:
	Events.can_pause.emit(!value)
	get_tree().paused = value


func _on_events_player_died() -> void:
	save_game()
	get_tree().paused = true
	Events.can_pause.emit(false)
	SceneTransition.transition_ready.connect(reload_scene, CONNECT_ONE_SHOT)
	pause_ui.handle_game_over(PauseScreens.RELOAD_SCREEN)


func _on_events_game_complete() -> void:
	save_game()
	get_tree().paused = true
	Events.can_pause.emit(false)
	GameData.handle_game_complete()
	
	
#endregion
#region DEPRECATED
func reset_map_starting_coords():
	pass
	#$UI/MapWindow.reset_starting_coords()
#endregion
