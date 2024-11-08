extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd"
class_name Game

const SaveManager = preload("res://addons/MetroidvaniaSystem/Template/Scripts/SaveManager.gd")
const SAVE_PATH = "user://example_save_data.sav"
# The game starts in this map. Note that it's scene name only, just like MetSys refers to rooms.
@export var starting_map: String
@export var custom_run: bool # For Custom Runner integration.
@export_category("Setup")
@export var level_manager: Node2D
@export var game_ui: GameUI
@export var day_night: DayNight
#@export var play_time_label: Label
# The coordinates of generated rooms. MetSys does not keep this list, so it needs to be done manually.
var generated_rooms: Array[Vector3i]


static var instance: Game
func _init() -> void:
	if instance == null: print("Previous instance: " + str(self))
	instance = self

signal new_second(play_time: float)
var total_play_time: float
var last_second: int = -1
var play_time: float:
	set(value):
		play_time = value
		var current_second: int = int(play_time)
		if current_second == last_second: return
		last_second = current_second
		new_second.emit(play_time)
func _process(delta: float) -> void:
	total_play_time += delta
	play_time += delta
	
#region Signal Functions
func _on_events_dialogue_toggle(value: bool) -> void:
	Events.can_pause.emit(!value)
	get_tree().paused = value
	
func _on_events_player_died() -> void:
	get_tree().paused = true
	Events.can_pause.emit(false)
	SceneTransition.fade_out_in()
	await SceneTransition.transition_ready
	(player as TestPlayer).kill()
	get_tree().paused = false
	Events.can_pause.emit(true)

func _on_day_night_time_tick(day:int, hour:int, minute:int) -> void:
	if hour == 8 || hour == 19:
		var player: TestPlayer = TestPlayer.instance
		player.on_day_night(hour)
		game_ui.on_day_night(hour)
	#if hour == 
#endregion

func _ready() -> void:
	#NOTE connect signals
	Events.game_ready.emit()
	Events.dialogue_toggle.connect(_on_events_dialogue_toggle)
	Events.player_died.connect(_on_events_player_died)
	game_ui.setup(self)
	day_night.time_tick.connect(_on_day_night_time_tick)
	
	MetSys.reset_state() # Make sure MetSys is in initial state.
	set_player($TestPlayer) # Assign player for MetSysGame.
	
	if FileAccess.file_exists(SAVE_PATH):
		# If save data exists, load it using MetSys SaveManager.
		var save_manager := SaveManager.new()
		save_manager.load_from_text(SAVE_PATH)
		# Assign loaded values.
		generated_rooms.assign(save_manager.get_value("generated_rooms"))
		
		if not custom_run: #NOTE Get the saved map & set it as the starting_map
			var loaded_starting_map: String = save_manager.get_value("current_room")
			if not loaded_starting_map.is_empty(): # Some compatibility problem.
				starting_map = loaded_starting_map
		
	else:
		# If no data exists, set empty one.
		MetSys.set_save_data()
	
	# Initialize room when it changes.
	room_loaded.connect(init_room, CONNECT_DEFERRED)
	# Load the starting room.
	load_room(starting_map)
	
	# Find the save point and teleport the player to it, to start at the save point.
	var start := map.get_node_or_null(^"SavePoint")
	if custom_run or !start: start = map.get_node_or_null(^"PlayerSpawn")
	if start:
		player.position = start.position
	
	# Reset position tracking (feature specific to this project).
	reset_map_starting_coords.call_deferred()
	add_module("RoomTransitions.gd") # Add module for room transitions.

# Save game using MetSys SaveManager.
func save_game():
	var save_manager := SaveManager.new()
	save_manager.set_value("current_room", MetSys.get_current_room_name())
	save_manager.save_as_text(SAVE_PATH)

func reset_map_starting_coords():
	pass
	#$UI/MapWindow.reset_starting_coords()

func init_room():
	MetSys.get_current_room_instance().adjust_camera_limits(%Camera2D)
	SceneTransition.fade_in()
	player.on_enter()


func _unhandled_input(event: InputEvent) -> void:
	if not OS.has_feature("editor"): return
	if event.is_action_pressed(GameConst.INPUT_SELECT):
		var music_bus: int = AudioConst.BUS_MUSIC_IDX
		AudioServer.set_bus_mute(music_bus, !AudioServer.is_bus_mute(music_bus))
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R:
				get_tree().reload_current_scene()
