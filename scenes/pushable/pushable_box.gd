class_name Pushable extends CharacterBody2D

@export var size: int = 32

@export var PUSH_FORCE: float = 500
@export var MAX_PUSH_SPEED: float = 400
@export var FRICTION: float = 5000

@onready var half_size: int = size / 2

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.x = 0
		position.x = round((position.x - half_size) / size) * size + half_size
		
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
