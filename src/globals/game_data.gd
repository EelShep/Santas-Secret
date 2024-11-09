extends Node

#region Data Keys
const CURR_ROOM: String = "current_room"
const PLAY_TIME: String = "play_time"
const DAY_TIME: String = "day_time"

#endregion 

var data: Dictionary = {}


func set_curr_room() -> void:
	data[CURR_ROOM] = MetSys.get_current_room_name()


func reset_data() -> void:
	data = {}

func load_data() -> Dictionary:
	return data
	
func save_data(_data: Dictionary) -> void:
	data.merge(_data, true)
	

func convert_time(_play_time : float) -> String:
	var total_seconds: int = int(_play_time)
	var seconds: int = total_seconds % 60
	var minutes: int = total_seconds / 60
	return &"%d : %02d" % [minutes, seconds]
