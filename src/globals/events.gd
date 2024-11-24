extends Node

signal main_menu_ready
signal game_ready
signal game_quit

signal can_pause(value: bool)
signal pause_toggled(value: bool)

signal dialogue_toggle(value: bool)

signal map_ready(area: int)

signal player_died() #NOTE Player Captured
signal game_over() #NOTE Time Expired
signal game_reset()

signal checkpoint_activated()
