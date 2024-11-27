extends Node


func _ready() -> void:
	Events.main_menu_ready.connect(reset_data)


func reset_data() -> void:
	FileAccess.open(SaveData.SAVE_PATH, FileAccess.WRITE).store_string("")

var credits_stats: bool = false
func get_data():
	var file = FileAccess.open(SaveData.SAVE_PATH, FileAccess.READ).get_as_text()
	print(file)
	

func convert_time(_play_time : float) -> String:
	var total_seconds: int = int(_play_time)
	var seconds: int = total_seconds % 60
	var minutes: int = total_seconds / 60
	return &"%d : %02d" % [minutes, seconds]
