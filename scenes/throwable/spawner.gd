extends Node2D


@export var spawnable: PackedScene

@export var DELAY: float = 0.2
var delay: float = 1.0
func _process(delta: float) -> void:
	delay -= delta
	if delay < 0:
		spawn()

func _ready() -> void:
	handle_spawn()


func handle_spawn() -> void:
	delay = DELAY
	set_process(true)


func spawn() -> void:
	set_process(false)
	var spawnable_inst: Node2D = spawnable.instantiate()

	spawnable_inst.position = position
	
	if spawnable_inst.has_signal("destroyed"):
		spawnable_inst.destroyed.connect(handle_spawn)

	var level: Level = Level.instance
	level.call_deferred("add_child", spawnable_inst)
	
