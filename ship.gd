# The player ship handles movement, shooting, and damage. The HUD listens
# for health changes so the ship can stay independent of the UI.
extends CharacterBody2D

signal health_changed(current_health: int, maximum_health: int)


# Exported settings can be tuned in the Inspector. Speed is in pixels per
# second and acceleration is in pixels per second squared.
@export var acceleration: float = 300.0
@export var max_speed: float = 450.0
# Currently unused because the ship snaps directly to the mouse angle.
@export var turn_speed: float = 4.0
@export var damage_protection_duration: float = 0.75
@export var bullet_scene: PackedScene
@export var bullet_speed: float = 650.0
@export var fire_interval: float = 0.2
@export var max_health: int = 10
# Dash duration is in seconds. Boost is extra speed at the start of the dash.
@export var dash_duration: float = 0.15
@export var dash_boost: float = 1000.0



# The Muzzle child marks where bullets appear. @onready resolves it when
# the ship and its children are ready.
@onready var muzzle: Marker2D = $Muzzle

# The dash remembers its starting direction and the ship's previous drift.
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

# Draw the triangle in local coordinates. Negative Y is the ship's nose.
func _draw() -> void:
	var points := PackedVector2Array([
		Vector2(0, -20),
		Vector2(-12, 14),
		Vector2(12, 14),
		Vector2(0, -20),
	])
	
	
	draw_polyline(points, Color.WHITE, 2.0, true)
	
	
# delta is the time in seconds for one physics tick.
func _physics_process(delta: float) -> void:
	# Count down temporary damage protection without going below zero.
	damage_protection_remaining = maxf(
		damage_protection_remaining - delta,
		0.0
	)
	
	
	# Subtract the ship position to get a direction in world space.
	var mouse_direction := get_global_mouse_position() - global_position
	
	
	# Keep the last aim when the cursor is on top of the ship. Add 90 degrees
	# because an angle of zero points right while the drawn nose points up.
	if mouse_direction.length_squared() > 0.001:
		global_rotation = mouse_direction.angle() + PI / 2.0

	# A fresh press starts one dash and locks its direction for the burst.
	if Input.is_action_just_pressed("dash") and dash_time_left <= 0.0:
		dash_direction = Vector2.UP.rotated(global_rotation)
		pre_dash_velocity = velocity
		
		if pre_dash_velocity.dot(dash_direction) < 0.0:
			pre_dash_velocity = Vector2.ZERO
			
		dash_time_left = dash_duration

	# Add a boost that fades linearly as the timer runs down. The ordinary
	# thrust and speed cap apply only outside the dash.
	if dash_time_left > 0.0:
		var boost_fraction := dash_time_left / dash_duration
		velocity = pre_dash_velocity + dash_direction * dash_boost * boost_fraction
	else:
		if Input.is_action_pressed("thrust"):
			var forward := Vector2.UP.rotated(rotation)
			velocity += forward * acceleration * delta

		velocity = velocity.limit_length(max_speed)

	# Move once using the chosen velocity, then inspect this tick's contacts.
	move_and_slide()

	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		var body := collision.get_collider()
		
		if body is Node and body.is_in_group("asteroids"):
			take_damage(body.get_impact_damage(velocity))

	# After the last dash movement, restore the velocity saved at takeoff.
	if dash_time_left > 0.0:
		dash_time_left = maxf(dash_time_left - delta, 0.0)
		if dash_time_left == 0.0:
			velocity = pre_dash_velocity

	# Wrap each axis so the ship reappears on the opposite edge.
	var screen_size := get_viewport_rect().size
	position.x = wrapf(position.x, 0.0, screen_size.x)
	position.y = wrapf(position.y, 0.0, screen_size.y)
	
	# Holding fire repeats shots at the configured interval.
	fire_cooldown = maxf(fire_cooldown - delta, 0.0)
	
	if Input.is_action_pressed("fire") and fire_cooldown <= 0.0:
		shoot()
		fire_cooldown = fire_interval
		
# Add the bullet to the game scene so it can travel independently of the ship.
func shoot() -> void:
	if bullet_scene == null:
		return
		
	var bullet = bullet_scene.instantiate()
	
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.global_rotation = global_rotation
	
	var forward := Vector2.UP.rotated(global_rotation)
	
	# The shot inherits the ship's drift as well as its own forward speed.
	bullet.velocity = velocity + forward * bullet_speed
	
	

# Ignore hits while protected or dead. Tell the HUD the new health before
# removing the ship so it can show the restart button at zero health.
func take_damage(amount: int) -> void:
	if health == 0 or damage_protection_remaining > 0.0:
		return
	health = maxi(health - amount, 0)
	damage_protection_remaining = damage_protection_duration
	health_changed.emit(health, max_health)
	
	if health == 0:
		queue_free()
