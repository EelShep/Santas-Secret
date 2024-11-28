extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var to_convert = []
	for i in get_children():
		if i is ElfConversion:
			to_convert.append(i)
	to_convert.shuffle()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($TileMaps/Moon, "position", Vector2(600,600), 3)
	tween.tween_property($TileMaps/Moon/Color, "modulate", Color.GREEN_YELLOW, 1)
	#var i: Node2D
	for i in to_convert:
		if randf() < 0.5:
			i.scale.x = -1
		tween.tween_callback(i.dark_conversion).set_delay(0.2)
	tween.tween_property($TileMaps/Moon/Color, "modulate", Color.WHITE, 1)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
