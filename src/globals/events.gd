extends Node

signal main_menu_ready
signal game_ready
signal credits_ready
signal game_quit

signal can_pause(value: bool)
signal pause_toggled(value: bool)

signal trigger_event(event_id: int)
signal trigger_dialogue(dialog_balloon: PackedScene, dialogue_resource: DialogueResource,\
	dialogue_title: String)
signal dialogue_toggle(value: bool)

signal map_ready(area: int)

signal player_died() #NOTE Player Captured
signal game_over() #NOTE Time Expired
signal game_reset()

signal boss_activated()
signal game_complete()

signal checkpoint_activated()
