class_name Level extends Node2D

enum Area {
	Area1 = -1,
	Area2 = 0
}

@export_category("Settings")
@export var id: int
@export var area: Area
@export_category("Components")
@export var tilemap_manager: TileMapManager
@export var enemy_manager: EnemyManager


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
	add_stacks()


var props = [preload("res://scenes/props/gift/gift_prop.tscn"), preload("res://scenes/props/gift/gift_prop2.tscn"), preload("res://scenes/props/gift/gift_prop3.tscn")]

func add_stacks():
	var num = 50
	var stacked = 7
	var walkable = []
	for i in EnemyManager.instance.map:
		if EnemyManager.instance.map[i].kind == EnemyManager.MapTileDataKind.WALKABLE:
			walkable.append(EnemyManager.instance.tilemap.map_to_local(i))
	walkable.shuffle()
	prints("adding stacks of gifts to", len(walkable))
	for i in min(num, len(walkable)):
		var stack_height = 0
		var stack_offset = walkable[i] + Vector2(8,16)
		for j in randi()%stacked:
			var prop = props[randi()%len(props)].instantiate()
			$BackgroundProps.add_child(prop)
			prop.position = stack_offset + Vector2(randi_range(-3,3),stack_height)
			stack_height -= prop.stack_height
