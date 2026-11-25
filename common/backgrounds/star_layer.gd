extends Node2D


@export var star_count: int = 350
@export var star_seed: int = 100
@export var minimum_radius: float = 0.5
@export var maximum_radius: float = 1.0
@export var star_color: Color = Color(0.7, 0.8, 1.0, 0.5)

const TILE_SIZE: float = 2048.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = star_seed
	
	for index in range(star_count):
		var star_position := Vector2(
			random.randf_range(3.0, TILE_SIZE - 3.0),
			random.randf_range(3.0, TILE_SIZE - 3.0)
		)
		
		var radius := random.randf_range(
			minimum_radius,
			maximum_radius
		)
		
		var color := star_color
		color.a *= random.randf_range(0.4, 1.0)
		
		draw_circle(star_position, radius, color)		
		
		
