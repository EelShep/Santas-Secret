class_name HurtArea
extends Area2D
#Signal when HurtArea collides with HitAreaComponent
signal damaged(hit_area: HitArea)

@export var invulnerable_duration : float = 0.2
var invulnerable_duration_timer : Timer = Timer.new()

var is_invulnerable : bool = false :
	set(value):
		is_invulnerable = value
		invulnerable_duration_timer.start(invulnerable_duration)
		get_child(0).set_deferred("disabled", is_invulnerable) #Child should be CollisionShape
		

func _ready() -> void:
	add_child(invulnerable_duration_timer)
	invulnerable_duration_timer.one_shot = true
	invulnerable_duration_timer.timeout.connect(handle_invulnerability_timeout)


func handle_invulnerability_timeout() -> void:
	is_invulnerable = false
