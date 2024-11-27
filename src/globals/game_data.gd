extends Node



func _ready() -> void:
	Events.main_menu_ready.connect(reset_data)


func reset_data() -> void:
	credits_stats = false
	FileAccess.open(SaveData.SAVE_PATH, FileAccess.WRITE).store_string("")


func get_data():
	var file = FileAccess.open(SaveData.SAVE_PATH, FileAccess.READ).get_as_text()
	print(file)

var credits_stats: bool = false
func handle_game_complete() -> void:
	credits_stats = true
	SceneTransition.fade_out_in()
	await SceneTransition.transition_ready
	get_tree().change_scene_to_file(SceneTransition.CREDITS_SCENE_PATH)


func convert_time(_play_time : float) -> String:
	var total_seconds: int = int(_play_time)
	var seconds: int = total_seconds % 60
	var minutes: int = total_seconds / 60
	return &"%d : %02d" % [minutes, seconds]
