class_name DayNight extends CanvasModulate

signal time_tick(day:int, hour:int, minute:int)

const MINUTES_PER_DAY: int = 1440
const MINUTES_PER_HOUR: int = 60
const GAME_MINUTE_DURATION: float = (2 * PI) / MINUTES_PER_DAY

@export var gradient_texture: GradientTexture1D
@export_category("Settings")
@export var game_speed: float = 1.0
@export var initial_hour: int = 1:
	set(hour):
		initial_hour = hour
		time = GAME_MINUTE_DURATION * initial_hour * MINUTES_PER_HOUR

var time: float = 0.0
var past_minute:float = -1.0

func _ready() -> void:
	time = GAME_MINUTE_DURATION * initial_hour * MINUTES_PER_HOUR

func _process(delta: float) -> void:
	time += delta * GAME_MINUTE_DURATION * game_speed
	var value: float = (sin(time - PI / 2.0) + 1.0) / 2.0
	color = gradient_texture.gradient.sample(value)
	
	recalculate_time()
	
func recalculate_time() -> void:
	# Approx in game minutes passed
	var total_minutes = int(time / GAME_MINUTE_DURATION)
	
	var day = int(total_minutes / MINUTES_PER_DAY)
	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	
	var hour = int(current_day_minutes / MINUTES_PER_HOUR)
	var minute = int(current_day_minutes % MINUTES_PER_HOUR)
	
	if past_minute != minute:
		past_minute = minute
		time_tick.emit(day, hour, minute)
