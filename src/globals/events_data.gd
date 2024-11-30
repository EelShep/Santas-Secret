extends Node

var dialogues: Array = []
var events: Array = []

var boss_active: bool = false

func _ready() -> void:
	Events.trigger_event.connect(_on_events_trigger_event)
	Events.trigger_dialogue.connect(_on_events_trigger_dialogue)
	
	Events.game_ready.connect(func() -> void: boss_active = false)
	Events.boss_activated.connect(func() -> void: boss_active = true)


func reset_data() -> void:
	events.clear()


func _on_events_trigger_dialogue(dialog_balloon, dialogue_resource, dialogue_title) -> void:
	if dialogues.has(dialogue_title):
		match dialogue_title:
			"start":
				return
	else: dialogues.append(dialogue_title)	
	
	var balloon : Node = dialog_balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_title)


func _on_events_trigger_event(event_id: int) -> void:
	if event_id == 0: return
	
	if not events.has(event_id):
		events.append(event_id)
	
	print(event_id)
