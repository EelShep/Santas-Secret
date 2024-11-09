class_name Interactable extends Area2D


func _ready() -> void:
	body_entered.connect(handle_enter)
	body_exited.connect(handle_exit)
	#collision_layer = GameConst.COLLISION_INTERACTABLE
	#collision_mask = GameConst.COLLISION_PLAYER
	#print("hello")


func handle_action() -> void:
	pass

	
func handle_enter(_body: Node2D) -> void:
	pass


func handle_exit(_body: Node2D) -> void:
	pass
