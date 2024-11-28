extends CanvasLayer

const MAIN_MENU_SCENE_PATH: String = "res://scenes/main/main_menu.tscn"
const INTRO_CUTSCENE_PATH: String = "res://scenes/cutscenes/cutscene.tscn"
const GAME_SCENE_PATH: String = "res://scenes/main/game.tscn"
const CREDITS_SCENE_PATH: String = "res://scenes/main/credits.tscn"

signal transition_ready()

@export var animation_player: AnimationPlayer


func fade_in() -> void:
	animation_player.stop()
	animation_player.play("fade_in")

func fade_out() -> void:
	animation_player.stop()
	animation_player.play("fade_out")
	
func fade_out_in() -> void:
	animation_player.stop()
	animation_player.play("fade_out_in")


func signal_transition_ready() -> void:
	transition_ready.emit()
