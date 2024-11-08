extends Interactable

@export var dialog_balloon : PackedScene
# Dialogue file and start positions
@export var dialogue_resource : DialogueResource
@export var dialogue_start : String = "start"
@export_category("Prompt")
@export var canvas_layer: CanvasLayer
@export var prompt_control: Control

var show_delay: bool = true

func _ready() -> void:
	super()
	canvas_layer.hide()
	prompt_control.hide()
	get_tree().create_timer(0.25).timeout.connect(func(): 
		show_delay = false
	)
	

func handle_action() -> void:
	if not dialog_balloon or not dialogue_resource: return
	if get_tree().paused == true: return
	canvas_layer.hide()
	prompt_control.hide()
	var balloon : Node = dialog_balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_start)


func handle_enter(body: Node2D) -> void:
	if show_delay: return
	canvas_layer.show()
	prompt_control.show()


func handle_exit(body: Node2D) -> void:
	canvas_layer.hide()
	prompt_control.hide()