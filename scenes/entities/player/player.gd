class_name Player extends CharacterBody2D

const SPEED_MIN = 300.0
const SPEED_MAX = 400.0
const ACCEL = 50.0
const JUMP_VELOCITY = -450.0
const MAX_FALL_SPEED = 900.0
const COYOTE_TIME: float = .1
const SHORT_HOP: float = .5

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var animation: String

var reset_position: Vector2
# Indicates that the player has an event happening and can't be controlled.
var event: bool

var abilities: Array[StringName]
var double_jump: bool
var prev_on_floor: bool
var airtime: float = 0
var speed: float = SPEED_MIN
var can_pick = false

@export var footstep_player: AudioStreamPlayer2D

@export var hurt_area: HurtArea
@export var interaction_finder: Area2D

static var instance: Player
func _init() -> void:
	if instance == null: print("Previous instance: " + str(self))
	instance = self

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(GameConst.INPUT_INTERACT):
		var areas = interaction_finder.get_overlapping_areas()
		print(areas.size())
		if areas.size() < 1: return
		for area in areas:
			if area is Interactable: (area as Interactable).handle_action()

func _ready() -> void:
	hurt_area.damaged.connect(_on_hurt_area_damaged)
	on_enter()



func _physics_process(delta: float) -> void:
	if event:
		return
	
	if not is_on_floor():
		velocity.y = min(velocity.y + gravity * delta, MAX_FALL_SPEED)
		airtime += delta
	elif not prev_on_floor and &"double_jump" in abilities:
		# Some simple double jump implementation.
		double_jump = true
		airtime = 0
	
	# NOTE Landing SFX
	if is_on_floor() and not prev_on_floor:
		footstep()
	
	var on_floor_ct: bool = is_on_floor() or airtime < COYOTE_TIME
	if Input.is_action_just_pressed(GameConst.INPUT_JUMP) and (on_floor_ct or double_jump):
		if not on_floor_ct:
			double_jump = false
		
		if Input.is_action_pressed(GameConst.INPUT_MOVE_DOWN):
			position.y += 8
		else:
			velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_released(GameConst.INPUT_JUMP):
		if not is_on_floor() and velocity.y < 0:
			velocity.y = min(0, velocity.y - JUMP_VELOCITY * SHORT_HOP)
			
	
	if is_on_wall():
		speed = SPEED_MIN
	
	var direction := Input.get_axis(GameConst.INPUT_MOVE_LEFT, GameConst.INPUT_MOVE_RIGHT)
	if direction:
		speed = min(SPEED_MAX, speed + ACCEL * delta)
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED_MIN)
		speed = SPEED_MIN

	prev_on_floor = is_on_floor()
	move_and_slide()
	
	var new_animation = &"Idle"
	if velocity.y < 0:
		new_animation = &"Jump"
	elif velocity.y >= 0 and not is_on_floor():
		new_animation = &"Fall"
	elif absf(velocity.x) > 1:
		new_animation = &"Run"
	
	if new_animation != animation:
		animation = new_animation
		$AnimationPlayer.play(new_animation)
	
	if velocity.x > 1:
		$Sprite2D.flip_h = false
	elif velocity.x < -1:
		$Sprite2D.flip_h = true


func footstep() -> void:
	var tilemap_manager: TileMapManager = Level.instance.tilemap_manager
	var tilemap: TileMapLayer = tilemap_manager.ground_tiles
	var vertical_offset: Vector2 = Vector2(0, 10)
	var tile_pos: Vector2 = tilemap.local_to_map(position + vertical_offset)
	var custom_data = tilemap_manager.get_tile_custom_data(tilemap, tile_pos, TileMapManager.GROUND_TYPE)
	var footstep_sfx_stream: AudioStreamRandomizer = AudioConst.RES_INDOOR_FOOTSTEPS
	if custom_data == TileMapManager.GROUND_SNOW:
		footstep_sfx_stream = AudioConst.RES_SNOW_FOOTSTEPS
	footstep_player.stream = footstep_sfx_stream
	footstep_player.play()
	

func stun() -> void:
	print("stunned")

func kill() -> void:
	AudioController.play_sfx(AudioConst.SFX_PLAYER_DEATH)
	Events.player_died.emit()
	# Player dies, reset the position to the entrance.
	#position = reset_position

func _on_hurt_area_damaged(hit_area: HitArea) -> void:
	match hit_area.type:
		HitArea.Type.Stun:
			stun()
		HitArea.Type.Kill:
			kill()

func on_enter():
	# Position for kill system. Assigned when entering new room (see Game.gd).
	reset_position = position
	
func on_day_night(hour: int) -> void:
	var value: bool = hour > 18
	$PointLight2D.enabled = value
