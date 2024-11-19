extends Area2D

@export var fake_area_cover: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", body_entered)
	connect("body_exited", body_exited)


func body_entered(body):
	if body is Player:
		if fake_area_cover:
			fake_area_cover.hide()


func body_exited(body):
	if body is Player:
		if fake_area_cover:
			fake_area_cover.show()
		
