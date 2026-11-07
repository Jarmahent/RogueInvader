extends CharacterBody2D

signal health_changed(current_health: int, maximum_health: int)


@export var acceleration: float = 300.0
@export var max_speed: float = 450.0
@export var turn_speed: float = 4.0
@export var damage_protection_duration: float = 0.75
@export var bullet_scene: PackedScene
@export var bullet_speed: float = 650.0
@export var fire_interval: float = 0.2
@export var max_health: int = 10
@export var dash_duration: float = 0.15
@export var dash_boost: float = 1000.0



@onready var muzzle: Marker2D = $Muzzle

var dash_time_left: float = 0.0
var dash_direction := Vector2.ZERO
var pre_dash_velocity := Vector2.ZERO
var health: int
var fire_cooldown: float = 0.0
var damage_protection_remaining = 0.0

func _ready() -> void:
	health = max_health
	
	# Treat all collision surfaces as walls, with no floor.
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

	# Start in the middle of the game window.
	position = get_viewport_rect().size / 2.0

func _draw() -> void:
	var points := PackedVector2Array([
		Vector2(0, -20),
		Vector2(-12, 14),
		Vector2(12, 14),
		Vector2(0, -20),
	])
	
	
	draw_polyline(points, Color.WHITE, 2.0, true)
	
	
func _physics_process(delta: float) -> void:
	damage_protection_remaining = maxf(
		damage_protection_remaining - delta,
		0.0
	)
	
	
	var mouse_direction := get_global_mouse_position() - global_position
	
	
	if mouse_direction.length_squared() > 0.001:
		global_rotation = mouse_direction.angle() + PI / 2.0

	if Input.is_action_just_pressed("dash") and dash_time_left <= 0.0:
		pre_dash_velocity = velocity
		dash_direction = Vector2.UP.rotated(global_rotation)
		dash_time_left = dash_duration

	if dash_time_left > 0.0:
		var boost_fraction := dash_time_left / dash_duration
		velocity = pre_dash_velocity + dash_direction * dash_boost * boost_fraction
	else:
		if Input.is_action_pressed("thrust"):
			var forward := Vector2.UP.rotated(rotation)
			velocity += forward * acceleration * delta

		velocity = velocity.limit_length(max_speed)

	move_and_slide()

	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		var body := collision.get_collider()
		
		if body is Node and body.is_in_group("asteroids"):
			take_damage(body.get_impact_damage(velocity))

	if dash_time_left > 0.0:
		dash_time_left = maxf(dash_time_left - delta, 0.0)
		if dash_time_left == 0.0:
			velocity = pre_dash_velocity

	var screen_size := get_viewport_rect().size
	position.x = wrapf(position.x, 0.0, screen_size.x)
	position.y = wrapf(position.y, 0.0, screen_size.y)
	
	fire_cooldown = maxf(fire_cooldown - delta, 0.0)
	
	if Input.is_action_pressed("fire") and fire_cooldown <= 0.0:
		shoot()
		fire_cooldown = fire_interval
		
func shoot() -> void:
	if bullet_scene == null:
		return
		
	var bullet = bullet_scene.instantiate()
	
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.global_rotation = global_rotation
	
	var forward := Vector2.UP.rotated(global_rotation)
	
	bullet.velocity = velocity + forward * bullet_speed
	
	

func take_damage(amount: int) -> void:
	if health == 0 or damage_protection_remaining > 0.0:
		return
	health = maxi(health - amount, 0)
	damage_protection_remaining = damage_protection_duration
	health_changed.emit(health, max_health)
	
	if health == 0:
		queue_free()
