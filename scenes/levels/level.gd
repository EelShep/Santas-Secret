class_name Level extends Node2D

enum Area {
	Area1 = -1,
	Area2 = 0
}

@export var id: int
@export var area: Area

static var instance: Level
func _init() -> void:
	if instance == null: print("Previous instance: " + str(self))
	instance = self


func _ready() -> void:
	Events.map_ready.emit(area)
	if EnemyManager.instance and has_node("Enemies"):
		var enemies = []
		for item in get_node("Enemies").get_children():
			if item is Enemy:
				enemies.append(item)
		EnemyManager.instance.register($TileMaps/Ground, enemies)
