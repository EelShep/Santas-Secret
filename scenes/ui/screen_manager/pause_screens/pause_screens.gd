class_name PauseScreens extends ScreensManager

const PAUSE_SCREEN: int = 0
const RELOAD_SCREEN: int = 1
const GAME_OVER_SCREEN: int = 2

const OPTIONS_SCREENS: int = 0

func _on_button_pressed(button: ScreenButton) -> void:
	match button.name:
		#region Pause Buttons
		"PauseResume":
			exit_screens.emit(self, true)
			change_screen(null)
		"PauseOptions":
			change_screen(null)
			screen_managers[OPTIONS_SCREENS].on_enter()
		"PauseQuit":
			SceneTransition.fade_out_in()
			await SceneTransition.transition_ready
			get_tree().change_scene_to_file(SceneTransition.MAIN_MENU_SCENE_PATH)
		"ReloadReload":
			get_tree().reload_current_scene()
		"ReloadQuit":
			get_tree().change_scene_to_file(SceneTransition.MAIN_MENU_SCENE_PATH)
		"GameOverRestart":
			Events.game_reset.emit()
			get_tree().reload_current_scene()
		"GameOverQuit":
			get_tree().change_scene_to_file(SceneTransition.MAIN_MENU_SCENE_PATH)


func _on_screen_exit(screen: Screen, exit_all: bool = false) -> void:
	if screen == screens[PAUSE_SCREEN] or exit_all or screen.always_exit:
		change_screen(null)
		exit_screens.emit(self, exit_all)
	else: change_screen(screens[PAUSE_SCREEN])
