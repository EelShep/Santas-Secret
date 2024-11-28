extends Node

const CURR_ROOM: String = "current_room"
const GENERATED_ROOMS: String = "generated_rooms"
const PLAY_TIME: String = "play_time"
const DAY_TIME: String = "day_time"
const STARTING_MAP: String = "start.tscn"
const INITIAL_LOAD: String = "initial_load"

func _ready() -> void:
	Events.main_menu_ready.connect(_on_events_main_menu_ready)

#region DATA FUNCTIONS
func reset_data() -> void:
	credits_stats = false


func reset_save() -> void:
	FileAccess.open(SaveData.SAVE_PATH, FileAccess.WRITE).store_string("")


func get_data():
	var file = FileAccess.open(SaveData.SAVE_PATH, FileAccess.READ)
	var loaded_data = str_to_var(file.get_as_text())
	return loaded_data
#endregion
#region EVENT FUNCTIONS
var credits_stats: bool = false
func handle_game_complete() -> void:
	credits_stats = true
	SceneTransition.fade_out_in()
	await SceneTransition.transition_ready
	get_tree().change_scene_to_file(SceneTransition.CREDITS_SCENE_PATH)


func _on_events_main_menu_ready() -> void:
	reset_data()
	reset_save()
#endregion
#region HELPER FUNCTIONS
func convert_time(_play_time : float) -> String:
	var total_seconds: int = int(_play_time)
	var seconds: int = total_seconds % 60
	var minutes: int = total_seconds / 60
	return &"%d : %02d" % [minutes, seconds]
#endregion
