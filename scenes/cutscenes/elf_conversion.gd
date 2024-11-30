extends Node2D
class_name ElfConversion


@export var audio_player: AudioStreamPlayer2D

@export var converted = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$base.material = $base.material.duplicate()
	$base.material.set_shader_parameter("row", randf())
	$skin.material = $skin.material.duplicate()
	$skin.material.set_shader_parameter("row", randf())
	

func dark_conversion():
	converted = true
	$CPUParticles2D.emitting = true
	$eyes.hide()
	$"eyes-dark".show()
	$skin.material.set_shader_parameter("palette", preload("res://assets/visual/elves/skin-dark-palette.png"))
	$skin.material.set_shader_parameter("skip_first_row", true)
	$skin.material.set_shader_parameter("row", 1.0)
	
	audio_player.pitch_scale = randf_range(0.9, 1.1)
	audio_player.play()
	
