extends Node2D


@export var asteroid_scene: PackedScene
@export var spawn_delay: float = 1.0
@export var max_asteroids: int = 5
@export var spawn_interval: float = 2.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(spawn_delay).timeout
	while(is_inside_tree()):
		if not is_instance_valid(get_node_or_null("Ship")):
			return
		var asteroid_count := get_tree().get_nodes_in_group("asteroids").size()
		
		if asteroid_count < max_asteroids:
			spawn_asteroid()
		await get_tree().create_timer(spawn_interval).timeout
	
	
func spawn_asteroid() -> void:
	var screen_size := get_viewport_rect().size
	var ship_position: Vector2 = $Ship.position
	
	var spawn_position := Vector2(
		screen_size.x * 0.75 if ship_position.x < screen_size.x * 0.5
		else screen_size.x * 0.25,
		screen_size.y * 0.75 if ship_position.y < screen_size.y * 0.5
		else screen_size.y * 0.25
	)
	
	
	var asteroid = asteroid_scene.instantiate()
	asteroid.position = spawn_position
	asteroid.collision_layer = 2
	asteroid.collision_mask = 3
	asteroid.add_to_group("asteroids")
	
	add_child(asteroid)
