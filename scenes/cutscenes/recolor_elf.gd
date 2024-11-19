extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in 24:
		for y in 16:
			var elf = $Elf1.duplicate()
			elf.position = Vector2.ONE * 32 + Vector2(x,y) * 32
			elf.material = elf.material.duplicate()
			elf.material.set_shader_parameter("row", randf())
			add_child(elf)
			elf = $Elf2.duplicate()
			elf.position = Vector2.ONE * 32 + Vector2(x,y) * 32
			elf.material = elf.material.duplicate()
			elf.material.set_shader_parameter("row", randf())
			add_child(elf)

			
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
