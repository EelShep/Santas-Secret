class_name DayNight extends CanvasModulate

signal time_tick(day:int, hour:int, minute:int)

const MINUTES_PER_DAY: int = 1440
const MINUTES_PER_HOUR: int = 60
const GAME_MINUTE_DURATION: float = (2 * PI) / MINUTES_PER_DAY

@export var gradient_texture: GradientTexture1D
@export_category("Settings")
@export var game_speed: float = 1.0

var hour: int = 0:
	set(hour):
		hour = hour
		time = GAME_MINUTE_DURATION * hour * MINUTES_PER_HOUR

var time: float = 0.0
var past_minute:float = -1.0


func setup(game: Game) -> void:
	if game.day_time < 0.0:
		hour = game.INITIAL_HOUR
	else: time = game.day_time


func _ready() -> void:
	time = GAME_MINUTE_DURATION * hour * MINUTES_PER_HOUR


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
