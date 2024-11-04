extends Node
var speed = 10;
var delta

func _controller(event:InputEvent) -> void:
	if event.is_action_just_pressed("MoveLeft"):
		position.x -= speed * inputDirection;
	if event.is_action_pressed("MoveRight"):
		position.x += speed * inputDirection;
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
