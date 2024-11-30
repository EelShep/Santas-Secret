extends Area2D

@export var sprite: AnimatedSprite2D
@export var action_timer: Timer

enum NPC{Castor, Lyle, Hermes}
enum NPCState{Idle, PlayerNear}
var current_state : NPCState
var player: Player


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	action_timer.timeout.connect(_on_action_timer_timeout)
	current_state = NPCState.Idle


func _process(delta: float) -> void:
	match current_state:
		NPCState.Idle:
			return
		NPCState.PlayerNear:
			if !player:
				current_state = NPCState.Idle
				return
				
			var player_position = player.position - position
			if player_position.x < 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		current_state = NPCState.PlayerNear

	
func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		current_state = NPCState.Idle
		player = null


func _on_action_timer_timeout() -> void:
	if current_state == NPCState.PlayerNear: return
	sprite.flip_h = !sprite.flip_h
