extends Node2D

#@export var colors = ["f7f3c3", "ffd445", "ff2424", "8815b2", "4da6ff","116666","8fde5d"]
@export var colors = ["f7f3c3", "ffd445", "473650", "9ae7ec","456f81", "68ba58"]

@export var stack_height = 14
@export var height = 14
@export var width = 16
@export var wraps = 5
func _ready() -> void:
	colors.shuffle()
	var wrap = randi()%wraps
	$wrap.region_rect = Rect2(width*wrap,0,width,height)
	$base.modulate = Color(colors[0])
	$wrap.modulate = Color(colors[1])
	$bow1.modulate = Color(colors[2])
	$bow2.modulate = Color(colors[2])
