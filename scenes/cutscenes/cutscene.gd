extends Node2D

@export var animation_player: AnimationPlayer

var input_allowed: bool = false
func _input(event: InputEvent) -> void:
	if input_allowed && \
	(event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton) || \
	(event is InputEventJoypadButton): #or event is InputEventJoypadMotion):
		proceed_to_game()

func proceed_to_game() -> void:
	input_allowed = false
	SceneTransition.fade_out_in()
	await SceneTransition.transition_ready
	get_tree().change_scene_to_file(SceneTransition.GAME_SCENE_PATH)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var to_convert = []
	for i in get_children():
		if i is ElfConversion:
			to_convert.append(i)
	to_convert.shuffle()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($TileMaps/Moon, "position", Vector2(600,600), 3)
	tween.tween_property($TileMaps/Moon/Color, "modulate", Color.GREEN_YELLOW, 1)
	#var i: Node2D
	for i in to_convert:
		if randf() < 0.5:
			i.scale.x = -1
		tween.tween_callback(i.dark_conversion).set_delay(0.2)
	tween.tween_property($TileMaps/Moon/Color, "modulate", Color.WHITE, 1)
	
const INPUT_DELAY: float = 15.0
@export var input_delay: float
func _process(delta: float) -> void:
	input_delay -= delta
	if input_delay >= 0.0: return
	handle_cutscene_finished()
	set_process(false)


func handle_cutscene_finished() -> void:
	input_allowed = true
	animation_player.play("flash_prompt")
