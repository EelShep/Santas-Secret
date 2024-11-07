extends Node

func convert_time(_play_time : float) -> String:
	var total_seconds: int = int(_play_time)
	var seconds: int = total_seconds % 60
	var minutes: int = total_seconds / 60
	return &"%d : %02d" % [minutes, seconds]
