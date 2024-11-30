class_name Throwable extends RigidBody2D 

signal destroyed

@export_category("Settings")
@export var throw_vel = 1000
@export_category("Components")
@export var hit_area: HitArea
@export var pick_area: Area2D
@export_category("Audio")
@export var throw_player: AudioStreamPlayer2D
@export var break_player: AudioStreamPlayer2D

var player: Player = Player.instance
@onready var object: RigidBody2D =$"."
@onready var throw_mark = get_tree().get_first_node_in_group("direction")
var picked = false
var gravity =10

var thrown: bool = false


func _ready() -> void:
	hit_area.damage_hurt_area.connect(_on_damage_hurt_area)
	contact_monitor = false
	hit_area.toggle_shape(false)
	

func _physics_process(delta: float) -> void:
	if picked == true:
		self.position = get_tree().get_first_node_in_group("direction").global_position


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pick"):
		var bodies = pick_area.get_overlapping_bodies()
		for body in bodies:
			if player and player.can_pick == true:
				picked = true
				player.can_pick = false
				player.speed -= 200

	if Input.is_action_just_pressed("throw") and picked == true:
		toggle_throw(true)
		picked = false
		player.can_pick = false
		object.transform = throw_mark.global_transform
		object.linear_velocity= object.transform.x * throw_vel
		object.gravity = gravity
		player.speed = 400
		
		if throw_player: throw_player.play()

func toggle_throw(value: bool) -> void:
	thrown = value
	contact_monitor = value
	hit_area.toggle_shape(value)
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	player.can_pick = true


func on_collided() -> void:
	toggle_throw(false)
	pick_area.set_deferred("monitoring", false)
	hide()
	
	break_player.play()
	await break_player.finished
	
	destroyed.emit()
	queue_free()

func _on_body_entered(body: Node) -> void:
	if thrown:
		on_collided()
	

func _on_damage_hurt_area(body: HurtArea) -> void:
	if thrown: 
		on_collided()
