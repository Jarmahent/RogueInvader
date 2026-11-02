extends CharacterBody2D

@export var max_health: int = 30
@export var drift_speed: float = 80.0

var health: int


func _ready() -> void:
	health = max_health
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

	# Pick a random direction, keeping the same drift speed.
	var angle := randf_range(0.0, TAU)
	velocity = Vector2.RIGHT.rotated(angle) * drift_speed


func _physics_process(_delta: float) -> void:
	move_and_slide()

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

	draw_polyline(points, Color.WHITE, 2.0, true)
