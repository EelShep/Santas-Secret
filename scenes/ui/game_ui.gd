class_name GameUI extends CanvasLayer

@export var play_time_label: Label
@export var day_night_label: Label
@export var timer: Timer

var displayed_label: Label = null


func setup(game_ref: Game) -> void:
	game_ref.new_second.connect(_on_game_new_second)
	timer.timeout.connect(_on_timer_timeout)


func display_message(message: String, time: float = 3.0) -> void:
	displayed_label = day_night_label
	displayed_label.show()
	displayed_label.text = message
	
	timer.start(time) 
	

func _on_game_new_second(play_time: float) -> void:
	play_time_label.text = GameData.convert_time(play_time)
	
func on_day_night(hour: float) -> void:
	displayed_label = day_night_label
	displayed_label.show()
	if hour == Game.MIDNIGHT_HOUR:
		display_message("The Morning fast approaches", 6.5)
	if not OS.has_feature("editor"): return
	if hour == Game.NIGHT_FALL_HOUR: displayed_label.text = "The sun has fallen" 
	elif hour == Game.SUN_RISE_HOUR: displayed_label.text = "The sun has risen"
	elif hour == Game.GAME_OVER_HOUR: displayed_label.text = "Game Over time reached"
	
	timer.start()

func _on_timer_timeout() -> void:
	if not displayed_label: return
	displayed_label.hide()
	displayed_label = null
