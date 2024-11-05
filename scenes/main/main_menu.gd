extends CanvasLayer

const GAME_SCENE_PATH: String = "res://scenes/main/game.tscn"

@export var main_menu_screens: MainMenuScreens
#TODO @export var quit_button: ScreenButton

func _ready() -> void:
	get_tree().paused = false
	Events.main_menu_ready.emit()

	main_menu_screens.start_game.connect(_on_play_pressed)
	main_menu_screens.quit_game.connect(_on_quit_pressed)
	main_menu_screens.on_enter()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_quit_pressed() -> void:
	get_tree().create_timer(0.5).timeout.connect(func() -> void: get_tree().quit())
	
