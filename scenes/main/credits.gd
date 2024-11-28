class_name CreditsScene extends CanvasLayer

const INPUT_DELAY: float = 1.5

@export var animation_player: AnimationPlayer
@export var input_delay: Timer

enum States{Credits, Thanks, Stats}
var curr_state: States = States.Credits

var input_allowed: bool = false

const ANIM_CREDITS: String = "credits"
const ANIM_THANKS: String = "thanks"
const ANIM_STATS: String = "stats"
const ANIM_PROMPT: String = "prompt_flash"


func _input(event: InputEvent) -> void:
	if input_allowed && \
	(event is InputEventKey or event is InputEventJoypadButton or event is InputEventMouseButton) || \
	(event is InputEventJoypadButton): #or event is InputEventJoypadMotion):
		match curr_state:
			States.Credits:
				show_thanks()
			States.Thanks:
				if GameData.credits_stats: 
					show_stats()
				else: 
					proceed_to_menu()
			States.Stats:
				proceed_to_menu()

func _ready() -> void:
	AudioController.play_music(AudioConst.MUSIC_TITLE)
	input_delay.timeout.connect(_on_input_delay_timeout)
	animation_player.animation_finished.connect(_on_animation_finished)
	
	%Credits.hide()
	%Stats.hide()
	%MenuPrompt.hide()

	show_credits()
	set_stats()

func _on_animation_finished(anim_name: String) -> void:
	match anim_name:
		ANIM_CREDITS:
			show_thanks()
		ANIM_THANKS:
			if GameData.credits_stats: 
				show_stats()
			elif input_allowed: 
				proceed_to_menu()
		ANIM_STATS:
			pass
		
	
func show_credits() -> void:
	curr_state = States.Credits
	hide_all()
	%Credits.show()
	input_allowed = false
	set_all_children_visibility(%Credits, true)
	animation_player.play(ANIM_CREDITS)
	input_delay.start(INPUT_DELAY * 2)



func show_thanks() -> void:
	curr_state = States.Thanks
	hide_all()
	%SpecialThanks.show()
	input_allowed = false
	set_all_children_visibility(%SpecialThanks, true)
	animation_player.play(ANIM_THANKS)
	input_delay.start(INPUT_DELAY)


func show_stats() -> void:
	if not GameData.credits_stats:
		show_menu_prompt()
		return
	input_allowed = false
	curr_state = States.Stats
	
	hide_all()
	%Stats.show()
	%MenuPrompt.hide()
	set_all_children_visibility(%Stats, true)
	
	animation_player.play(ANIM_STATS)
	input_delay.start(INPUT_DELAY)


func show_menu_prompt() -> void:
	%MenuPrompt.show()
	animation_player.play(ANIM_PROMPT)


func proceed_to_menu() -> void:
	input_allowed = false
	SceneTransition.fade_out_in()
	await SceneTransition.transition_ready
	get_tree().change_scene_to_file(SceneTransition.MAIN_MENU_SCENE_PATH)
	
	
func _on_input_delay_timeout() -> void:
	input_allowed = true
	if curr_state != States.Credits:
		show_menu_prompt()

#region Helper Functions
func set_stats() -> void:
	if not GameData.credits_stats: return
	var game_data: Variant = GameData.get_data()
	if not game_data or not game_data is Dictionary: return
	var play_time = (game_data as Dictionary).get(GameData.PLAY_TIME)
	if play_time:
		%PlayTimeValue.text = GameData.convert_time(play_time)

	
func set_all_children_visibility(node: Variant, value: bool) -> void:
	for child: Variant in node.get_children():
		if child is CanvasItem:
			child.visible = value
			set_all_children_visibility(child, value)

func hide_all()-> void:
	%Credits.hide()
	%SpecialThanks.hide()
	%Stats.hide()
#endregion
