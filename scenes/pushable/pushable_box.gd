class_name Pushable extends CharacterBody2D

const PUSH_FORCE: float = 500
const MAX_PUSH_SPEED: float = 400
const FRICTION: float = 5000

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.x = 0
		position.x = round((position.x - 32) / 64) * 64 + 32
		
	velocity.y += gravity * delta
	move_and_slide()
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

func is_on_top_of_box(pusher_pos: Vector2) -> bool:
	return pusher_pos.y < position.y


func push(dir: float, pusher_pos: Vector2) -> void:
	if is_on_top_of_box(pusher_pos): return
	velocity.x += PUSH_FORCE * dir
	if velocity.x > MAX_PUSH_SPEED: velocity.x = MAX_PUSH_SPEED
	if velocity.x < -MAX_PUSH_SPEED: velocity.x = -MAX_PUSH_SPEED