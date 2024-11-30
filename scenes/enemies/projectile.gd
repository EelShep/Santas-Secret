extends Area2D
class_name Projectile


var elapsed := 0.0
var speed := 600
var direction: Vector2

@export var throw_player: AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", projectile_impact)
	throw_player.play()


func projectile_impact(body):
	var tween = create_tween()
	var explosion_time = 0.3
	speed = 0.0
	tween.set_parallel(true)
	tween.tween_property($Projectile, "scale", $Projectile.scale * 5, explosion_time)
	tween.tween_property($Projectile, "modulate", Color(1,1,1,0), explosion_time)
	tween.tween_callback(queue_free).set_delay(explosion_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	translate(direction * speed * delta)
