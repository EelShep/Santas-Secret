extends Node

const CONFIG_PATH: String = "user://settings.cfg"
var config: ConfigFile = ConfigFile.new()

var new_save: bool = true

func _ready() -> void:
	# Config Data
	reset_config()
	load_config()

#region Config
func load_config() -> void:
	if config.load(CONFIG_PATH) == OK:
		load_video_config()
		load_audio_config()
	else: save_config()


func save_config() -> void:
	config.save(CONFIG_PATH)

	
func reset_config() -> void:
	var window_mode: Variant = DisplayServer.WINDOW_MODE_FULLSCREEN
	if OS.get_name() == "Web": window_mode = DisplayServer.WINDOW_MODE_WINDOWED
	config.set_value("video", "fullscreen", window_mode)
	for i in range(AudioConst.AUDIO_BUSES):
		config.set_value("audio", str(i), 0.5)
		
	
func load_video_config() -> void:
	var screen_type: Variant = config.get_value("video", "fullscreen")
	DisplayServer.window_set_mode(screen_type)


func load_audio_config() -> void:
	for i in range(3):
		var value: float = config.get_value("audio", str(i))
		AudioServer.set_bus_volume_db(i, AudioController.lerp_to_db(value))
#endregion
