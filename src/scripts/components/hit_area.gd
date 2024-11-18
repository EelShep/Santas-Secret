class_name HitArea
extends Area2D

enum Type {
	Stun,
	Kill
}

@export var type: Type = Type.Kill

var collision_shape

signal damage_hurt_area(hurt_area)


func _ready() -> void:
	area_entered.connect(_on_hurt_area_entered)
	
	var children = get_children()
	for child in children:
		if child == CollisionShape2D || CollisionPolygon2D:
			collision_shape = child


func toggle_shape(value):
	if collision_shape:
		collision_shape.set_deferred("disabled", value)


func _on_hurt_area_entered(hurt_area : HurtArea):
	#Verify hurt_area is the right type, and isn't in the invulnerable state
	if !hurt_area is HurtArea: return
	if hurt_area.is_invulnerable: return
	#Signal both the hit_area & hurt_area have collided
	damage_hurt_area.emit(hurt_area) #hit_area signal
	hurt_area.damaged.emit(self) #hurt_area signal
