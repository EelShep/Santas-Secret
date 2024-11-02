class_name Game extends Node2D

var time: float

func _ready() -> void:
	Events.game_ready.emit()
	
func _process(delta: float) -> void:
	time += delta
