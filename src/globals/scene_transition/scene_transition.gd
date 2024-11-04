extends CanvasLayer

signal transition_ready()

@export var animation_player: AnimationPlayer


func fade_in() -> void:
	animation_player.play("fade_in")

func fade_out() -> void:
	animation_player.play("fade_out")
	
func fade_out_in() -> void:
	animation_player.play("fade_out_in")


func signal_transition_ready() -> void:
	transition_ready.emit()
