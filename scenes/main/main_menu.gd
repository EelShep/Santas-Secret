extends CanvasLayer


@export var main_menu_screens: MainMenuScreens
#TODO @export var quit_button: ScreenButton

func _ready() -> void:
	get_tree().paused = false
	Events.main_menu_ready.emit()
	main_menu_screens.start_game.connect(_on_play_pressed)
	main_menu_screens.start_credits.connect(_on_credits_pressed)
	main_menu_screens.quit_game.connect(_on_quit_pressed)
	main_menu_screens.on_enter()


func _on_play_pressed() -> void:
	SceneTransition.fade_out()
	await SceneTransition.transition_ready
	get_tree().change_scene_to_file(SceneTransition.GAME_SCENE_PATH)


func _on_credits_pressed() -> void:
	SceneTransition.fade_out_in()
	await SceneTransition.transition_ready
	get_tree().change_scene_to_file(SceneTransition.CREDITS_SCENE_PATH)


func _on_quit_pressed() -> void:
	get_tree().create_timer(0.5).timeout.connect(func() -> void: get_tree().quit())
	
