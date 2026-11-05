extends CharacterBody2D

@export var max_health: int = 30
@export var min_drift_speed: float = 40.0
@export var max_drift_speed: float = 300.0
@export var size_multiplier: float = 1.0
@export var damage_per_speed: float = 0.1
@export var minimum_contact_damage: int = 5

@onready var health_bar: ProgressBar = $HealthBar


var health: int


func _ready() -> void:
	var shape := CircleShape2D.new()
	
	shape.radius = 30.0 * size_multiplier
	$CollisionShape2D.shape = shape
	
	health = max_health
	
	health_bar.max_value = max_health
	health_bar.value = health
	
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

	# Pick a random direction, keeping the same drift speed.
	var angle := randf_range(0.0, TAU)
	var speed := randf_range(min_drift_speed, max_drift_speed)
	velocity = Vector2.RIGHT.rotated(angle) * speed


func _physics_process(_delta: float) -> void:
	move_and_slide()
	
	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		var body := collision.get_collider()
		
		if body is Node and body.has_method("take_damage"):
			if not body.is_in_group("asteroids"):
				body.take_damage(get_impact_damage(body.velocity))
	

	var screen_size := get_viewport_rect().size
	position.x = wrapf(position.x, 0.0, screen_size.x)
	position.y = wrapf(position.y, 0.0, screen_size.y)


func _draw() -> void:
	var points := PackedVector2Array([
		Vector2(0, -30),
		Vector2(22, -20),
		Vector2(30, 2),
		Vector2(18, 24),
		Vector2(-5, 30),
		Vector2(-25, 15),
		Vector2(-28, -12),
		Vector2(-12, -26),
		Vector2(0, -30),
	])

	for index in range(points.size()):
		points[index] *= size_multiplier

	draw_polyline(points, Color.WHITE, 2.0, true)


func take_damage(amount: int) -> void:
	health = maxi(health - amount, 0)
	
	health_bar.value = health
	
	print("Asteroids health: ", health)
	
	if health == 0:
		queue_free()
	
	
func get_impact_damage(other_velocity: Vector2) -> int:
	var relative_speed := (velocity - other_velocity).length()
	return maxi(
		minimum_contact_damage,
		int(round(relative_speed * damage_per_speed))
	)
	
	
