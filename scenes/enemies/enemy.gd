class_name Enemy extends CharacterBody2D

const SPEED_MIN = 300.0
@export var SPEED_MAX = 250.0
const ACCEL = 50.0
const JUMP_VELOCITY = -450.0
const MAX_FALL_SPEED = 900.0
const COYOTE_TIME: float = .1
const SHORT_HOP: float = .5

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var animation: String

var reset_position: Vector2

var abilities: Array[StringName]
var double_jump: bool
var prev_on_floor: bool
var airtime: float = 0
var speed: float = SPEED_MIN
var can_pick = false


@export var interaction_finder: Area2D

#
	#if Input.is_action_just_pressed(GameConst.INPUT_JUMP) and (on_floor_ct or double_jump):
		#if not on_floor_ct:
			#double_jump = false
		#
		#if Input.is_action_pressed(GameConst.INPUT_MOVE_DOWN):
			#position.y += 8
		#else:
			#velocity.y = JUMP_VELOCITY
	#
	#if Input.is_action_just_released(GameConst.INPUT_JUMP):
		#if not is_on_floor() and velocity.y < 0:
			#velocity.y = min(0, velocity.y - JUMP_VELOCITY * SHORT_HOP)
			#

	#var direction := Input.get_axis(GameConst.INPUT_MOVE_LEFT, GameConst.INPUT_MOVE_RIGHT)
	#if direction:
		#speed = min(SPEED_MAX, speed + ACCEL * delta)
		#velocity.x = direction * speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED_MIN)
		#speed = SPEED_MIN



func _ready() -> void:
	on_enter()
	marker = $TargetMarker.duplicate()
	#marker.show()
	marker.modulate = annotation_color
	get_parent().call_deferred("add_child",marker)
	$TargetMarker.queue_free()


func _physics_process(delta: float) -> void:
	# pause enemies when player is paused
	if Player.instance.event:
		return
		
	if stun_time >= 0.0:
		handle_stun(delta)
		return
	$StunVisual.hide()
		
	check_player(delta)
	plan_movement(delta)
	movement()
	color_player()

	
	if not is_on_floor():
		velocity.y = min(velocity.y + gravity * delta, MAX_FALL_SPEED)
		airtime += delta
	elif not prev_on_floor and &"double_jump" in abilities:
		# Some simple double jump implementation.
		double_jump = true
		airtime = 0
	
	var on_floor_ct: bool = is_on_floor() or airtime < COYOTE_TIME
	
	if is_on_wall():
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

func kill():
	# Player dies, reset the position to the entrance.
	position = reset_position

func on_enter():
	# Position for kill system. Assigned when entering new room (see Game.gd).
	reset_position = position
	
func on_day_night(hour: int) -> void:
	var value: bool = hour > 18
	$PointLight2D.enabled = value


#extends CharacterBody2D
#
## --------- VARIABLES ---------- #
#
#@export_category("Player Properties") # You can tweak these changes according to your likings
#@export var move_speed : float = 350
#@export var jump_force : float = 800
#@export var gravity : float = 30
#@export var max_jump_count : int = 2
#var jump_count : int = 2
#
#@export_category("Toggle Functions") # Double jump feature is disable by default (Can be toggled from inspector)
#@export var double_jump : = false
#
#var is_grounded : bool = false
#var movement_enabled : bool = false
#
#@onready var player_sprite = $AnimatedSprite2D
@onready var spawn_point = position
#@onready var particle_trails = $ParticleTrails
#@onready var death_particles = $DeathParticles
@onready var sight := $RayCast2D as RayCast2D
@onready var aim := $RayCast2DFire as RayCast2D
#var player: CharacterBody2D = null
var marker: Node2D = null
#var plan_tiles: Rect2i = Rect2i(Vector2i.ZERO,Vector2i.ZERO)
var plan: Array = []
var coords: Vector2i
var planned_direction = 0
var planned_jump = false
var planned_timeout = 0.0
@export var always_active = false
@export var vigilant = true
@export var active = false
var inactive_timeout = 0.0
var patrolling = true
var caught = false
@export var can_walk = true
@export var can_jump = true
@export var can_fire = false
@export var annotation_color: Color = Color.CRIMSON

@export var fire_load_time = 0.5
@export var fire_cooldown_time = 1.0
var firing = false
var fired = false
#
#func _ready():
	##$Collision.connect("area_entered", _on_collision_body_entered)
	#$Collision.connect("body_entered", _on_collision_body_entered)
	#$Collision.connect("body_exited", _on_collision_body_exited)
	#player = Player.instance
#
func start_firing():
	$ProjectileLoad.show()
	$ProjectileLoad.scale = Vector2.ONE * 0.01
	var tween = create_tween()
	tween.tween_property($ProjectileLoad, "scale", Vector2.ONE*1.0, fire_load_time)
	tween.tween_callback(do_fire)
	firing = true	
		
var projectile_template = preload("res://scenes/enemies/projectile.tscn")
func do_fire():
	fired = true
	$ProjectileLoad.hide()
	var projectile = projectile_template.instantiate() as Projectile
	projectile.position = position + $RayCast2DFire.position
	projectile.direction = (Player.instance.position - position).normalized()
	get_parent().add_child(projectile)
	await get_tree().create_timer(fire_cooldown_time).timeout
	fired = false
	firing = false
#
		#
#
func check_player(delta):
	inactive_timeout += delta
	if inactive_timeout > 1.0:
		patrolling = true
	if not vigilant:
		return
	var position_offset = Vector2(0, -16.0)
	if Player.instance:
		sight.look_at(Player.instance.position + position_offset)
		if sight.is_colliding():
			if sight.get_collider() is Player:
				marker.position = sight.get_collision_point()
				if not active or patrolling:
					prints("activating", self)
					reset_planning()
					patrolling = false
					active = true
		if can_fire:
			aim.look_at(Player.instance.position + position_offset)
			if aim.is_colliding():
				if aim.get_collider() is Player:
					marker.position = sight.get_collision_point()
					if not firing:
						start_firing()
					
				
	#
	#
#
func reset_planning():
	prints("reset_planning", self, position, EnemyManager.instance.entity_position_to_coords(position), planned_timeout)
	planned_timeout = 0.0
	planned_direction = 0
	inactive_timeout = 0.0 
	planned_jump = false
	plan = []
	EnemyManager.instance.used_tiles = {}
#
func plan_movement(delta: float):
	if not active and not patrolling:
		return

	if plan:
		var current_goal = EnemyManager.instance.tilemap.map_to_local(plan[0]) + Vector2(0, 32)
		if velocity.x and abs(current_goal.x-position.x) <= 4:
			prints("stop walking")
			planned_direction = 0
		if abs(current_goal.x-position.x) < 8 and velocity.y == 0:
			check_plan()
		else:
			if position.x+4 < current_goal.x:
				planned_direction = 1
			elif position.x-4 > current_goal.x:
				planned_direction = -1
			#prints("cannot advance plan", abs(current_goal.x-position.x), velocity.y, plan[0], tilemap.local_to_map(position))
			planned_timeout += delta
			if planned_timeout > 1.0:
				reset_planning()
			
	else:
		var capabilities = []
		if !can_jump:
			capabilities = [EnemyManager.MapTileDataConnection.WALK]
		if !can_walk:
			return
		if active:
			var player_tile = EnemyManager.instance.entity_position_to_coords(Player.instance.position)
			player_tile = EnemyManager.instance.project_to_walkable(player_tile)
			plan = EnemyManager.instance.make_plan(EnemyManager.instance.entity_position_to_coords(position), player_tile, self, always_active, capabilities)
			prints("active_to", self, plan)
		elif patrolling:
			if EnemyManager.instance.entity_position_to_coords(position) != EnemyManager.instance.entity_position_to_coords(spawn_point):
				plan = EnemyManager.instance.make_plan(EnemyManager.instance.entity_position_to_coords(position), EnemyManager.instance.entity_position_to_coords(spawn_point), self, true, capabilities)
				prints("patrol_to", self, plan)
#
func check_plan():
	var tile = plan.pop_front()
	EnemyManager.instance.free_tile(tile)
	if not plan:
		prints("plan completed", self)
		active = always_active
		if not active:
			inactive_timeout = 0.0
		return
	else:
		prints("plan subgoal", self, len(plan), plan)
	planned_timeout = 0.0
	#EnemyManager.instance.show_path(plan, annotation_color)
	var coords = EnemyManager.instance.entity_position_to_coords(position)
	if abs(coords.x - plan[0].x) > 1 or plan[0].y < coords.y:
		prints("need to jump", coords, plan[0], abs(coords.x - plan[0].x), plan[0].y < coords.y)
		jump()
	if coords.x == plan[0].x:
		planned_direction = 0
	elif coords.x < plan[0].x:
		planned_direction = 1
		prints("going right")
	elif coords.x > plan[0].x:
		planned_direction = -1
		prints("going left")
#
func color_player():
	if active:
		if caught:
			$Sprite2D.modulate = Color.DARK_GREEN
		else:
			$Sprite2D.modulate = Color.FIREBRICK
	else:
		$Sprite2D.modulate = Color.NAVY_BLUE
		

func movement():
	velocity.x = planned_direction * SPEED_MAX
#
func jump():
	planned_jump = false
	velocity.y  = JUMP_VELOCITY
	
var stun_time := 0.0
func handle_stun(delta: float) -> void:
	stun_time -= delta
	$StunVisual.show()

@export var footstep_player: AudioStreamPlayer2D
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

@export var STUN_TIME: float = 1.2
func stun() -> void:
	if stun_time >= 0.0: return
	stun_time = STUN_TIME
