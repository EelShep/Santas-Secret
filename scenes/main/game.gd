class_name Game extends Node2D

signal new_second

@export var play_time_label: Label

var total_play_time: float
var last_second: int = -1
var play_time: float:
	set(value):
		play_time = value
		var current_second: int = int(play_time)
		if current_second == last_second: return
		last_second = current_second
		new_second.emit()


func _ready() -> void:
	Events.game_ready.emit()
	new_second.connect(_on_new_second)
	play_time = 0
	
func _process(delta: float) -> void:
	total_play_time += delta
	play_time += delta

func _on_new_second() -> void:
	play_time_label.text = GameData.convert_time(play_time)
