class_name MainMenuScreens extends ScreensManager

const MENU_SCREEN: int = 0
const OPTIONS_SCREENS: int = 0

signal start_game()
signal start_credits()
signal quit_game()


func _ready() -> void:
	super()
	change_screen(screens[MENU_SCREEN])


func on_enter(screen_id: int = 0) -> void:
	if screens[screen_id] != null: change_screen(screens[screen_id])


#region Signal Functions
func _on_button_pressed(button: ScreenButton) -> void:
	match button.name:
		"MainMenuStart":
			change_screen(null)
			start_game.emit()
		"MainMenuOptions":
			change_screen(null)
			screen_managers[OPTIONS_SCREENS].on_enter()
		"MainMenuCredits":
			change_screen(null)
			start_credits.emit()
		"MainMenuQuit":
			change_screen(null)
			quit_game.emit()


func _on_screen_exit(screen: Screen, exit_all: bool = false) -> void:
	if screen != screens[MENU_SCREEN]:
		change_screen(screens[MENU_SCREEN])

func _on_screen_manager_exited(screen: ScreensManager, exit_all: bool = false) -> void:
	change_screen(screens[MENU_SCREEN])
