extends Interactable

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
	Events.checkpoint_activated.emit()


func handle_enter(body: Node2D) -> void:
	if show_delay: return
	canvas_layer.show()
	prompt_control.show()


func handle_exit(body: Node2D) -> void:
	canvas_layer.hide()
	prompt_control.hide()
