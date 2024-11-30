class_name Trigger extends Area2D

@export var one_time: bool = true
@export var event: Event = Event.NONE

enum Event {
	NONE,
	Event1
}


func _ready() -> void:
	body_entered.connect(handle_enter)
	if one_time: MetSys.register_storable_object(self) 



func handle_enter(body: Node2D) -> void:
	if not body is Player: return
	
	Events.trigger_event.emit(event)
	for child in get_children():
		if child is Interactable:
			(child as Interactable).handle_action()
			
	if one_time: MetSys.store_object(self) #NOTE Store the trigger.
	queue_free()
