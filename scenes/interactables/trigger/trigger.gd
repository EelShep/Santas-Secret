class_name Trigger extends Area2D

@export var one_time: bool = true
@export var event: Event = Event.NONE

enum Event {
	NONE,
	Event1,
	BossActivate,
	BossEscape
}


func _ready() -> void:
	if EventsData.has_event(event):
		queue_free()
		return
	body_entered.connect(handle_enter)
	if one_time: MetSys.register_storable_object(self) 



func handle_enter(body: Node2D) -> void:
	if not body is Player: return
	
	if event == Event.BossEscape:
		if EventsData.boss_active: 
			Events.game_complete.emit()
		return

	if EventsData.has_event(event):
		queue_free()
		return
		
	Events.trigger_event.emit(event)
	for child in get_children():
		if child is Interactable:
			(child as Interactable).handle_action()
			
	match event:
		Event.BossActivate:
			Events.boss_activated.emit()
			
	if one_time: MetSys.store_object(self) #NOTE Store the trigger.
	queue_free()
