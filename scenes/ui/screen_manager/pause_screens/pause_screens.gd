class_name PauseScreens extends ScreensManager

const MAIN_MENU_SCENE_PATH: String = "res://scenes/main/main_menu.tscn"
const PAUSE_SCREEN: int = 0


func _on_button_pressed(button: ScreenButton) -> void:
	match button.name:
		#region Pause Buttons
		"PauseResume":
			exit_screens.emit(self, true)
			change_screen(null)
		"PauseQuit":
			SceneTransition.fade_out_in()
			await SceneTransition.transition_ready
			get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)


func _on_screen_exit(screen: Screen, exit_all: bool = false) -> void:
	if screen == screens[PAUSE_SCREEN] or exit_all or screen.always_exit:
		change_screen(null)
		exit_screens.emit(self, exit_all)
	else: change_screen(screens[PAUSE_SCREEN])