extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Area2D.connect("body_entered", body_entered)
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Circle, "modulate", Color(1,1,1,0.0), 0.15)
	tween.tween_callback(queue_free)

func body_entered(body: Node2D):
	if body is Enemy and body.has_method("stun"):
		body.stun()
