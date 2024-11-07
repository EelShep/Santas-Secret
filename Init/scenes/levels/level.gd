class_name Level extends Node2D

static var instance: Level
func _init() -> void:
	if instance == null: print("Previous instance: " + str(self))
	instance = self
