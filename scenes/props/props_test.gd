extends Node2D

var props = [preload("res://scenes/props/gift/gift_prop.tscn"), preload("res://scenes/props/gift/gift_prop2.tscn"), preload("res://scenes/props/gift/gift_prop3.tscn")]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var offset = Vector2(0, get_viewport_rect().size.y/2)
	var spread = Vector2(get_viewport_rect().size.x, 0)
	var num = 50
	var stacked = 7
	for i in num:
		var stack_height = 0
		var stack_offset = offset + spread * randf()
		for j in randi()%stacked:
			var prop = props[randi()%len(props)].instantiate()
			add_child(prop)
			prop.position = stack_offset + Vector2(randi_range(-3,3),stack_height)
			stack_height -= prop.stack_height


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
