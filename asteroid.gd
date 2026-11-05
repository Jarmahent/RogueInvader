extends RigidBody2D

@export var max_health: int = 30
@export var min_drift_speed: float = 40.0
@export var max_drift_speed: float = 300.0
@export var size_multiplier: float = 2.0
@export var damage_per_speed: float = 0.1
@export var minimum_contact_damage: int = 5

@onready var health_bar: ProgressBar = $HealthBar


var health: int


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)
	var shape := CircleShape2D.new()
	
	shape.radius = 30.0 * size_multiplier
	$CollisionShape2D.shape = shape
	
	max_health = clampi(int(round(30.0 * size_multiplier)), 1, 60)
	health = max_health
	
	health_bar.max_value = max_health
	health_bar.value = health
	

	# Pick a random direction, keeping the same drift speed.
	var angle := randf_range(0.0, TAU)
	var speed := randf_range(min_drift_speed, max_drift_speed)
	linear_velocity = Vector2.RIGHT.rotated(angle) * speed


func _process(_delta: float) -> void:
	health_bar.rotation = -global_rotation
	health_bar.global_position = global_position + Vector2(
		-health_bar.size.x / 2.0,
		30.0 * size_multiplier + 8.0
	)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var screen_size := get_viewport_rect().size
	var wrapped_transform := state.transform
	wrapped_transform.origin.x = wrapf(
		wrapped_transform.origin.x, 0.0, screen_size.x
	)
	
	wrapped_transform.origin.y = wrapf(
		wrapped_transform.origin.y, 0.0, screen_size.y
	)
	
	state.transform = wrapped_transform

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.has_method("take_damage"):
		if not body.is_in_group("asteroids"):
			body.take_damage(get_impact_damage(body.velocity))

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
	var relative_speed := (linear_velocity - other_velocity).length()
	return maxi(
		minimum_contact_damage,
		int(round(relative_speed * damage_per_speed))
	)
	
	
