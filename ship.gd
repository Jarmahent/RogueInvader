extends CharacterBody2D


@export var acceleration: float = 300.0
@export var max_speed: float = 450.0
@export var turn_speed: float = 4.0

@export var bullet_scene: PackedScene
@export var bullet_speed: float = 650.0
@export var fire_interval: float = 0.2

@onready var muzzle: Marker2D = $Muzzle

var fire_cooldown: float = 0.0

func _ready() -> void:
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
	var turn_input := Input.get_axis("turn_left", "turn_right")
	rotation += turn_input * turn_speed * delta
	
	if Input.is_action_pressed("thrust"):
		var forward := Vector2.UP.rotated(rotation)
		velocity += forward * acceleration * delta
		
	velocity = velocity.limit_length(max_speed)
	
	move_and_slide()
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
	
	var forward := Vector2.UP.rotated(global_rotation)
	
	bullet.velocity = velocity + forward * bullet_speed
	
	
	
	
		
