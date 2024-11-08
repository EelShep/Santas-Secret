class_name Map extends Node2D

enum Area {
	Area1 = -1,
	Area2 = 0
}

@export var id: int
@export var area: Area

static var instance: Map
func _init() -> void:
	if instance == null: print("Previous instance: " + str(self))
	instance = self


func _ready() -> void:
	Events.map_ready.emit(area)
