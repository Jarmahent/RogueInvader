# The Game scene runs the asteroid spawn loop for the current run.
extends Node2D


signal gold_changed(total: int)

# The Inspector supplies the asteroid scene and sets the timing and cap.
@export var asteroid_scene: PackedScene
@export var spawn_delay: float = 1.0
@export var max_asteroids: int = 5
@export var spawn_interval: float = 2.0


var gold: int = 0

func _on_gold_awarded(amount: int) -> void:
	var ship := get_node_or_null("Ship")
	if ship == null or ship.is_queued_for_deletion():
		return
	gold += amount
	gold_changed.emit(gold)
	print("Gold +%d | Total: %d" % [amount, gold])


# Wait before the first spawn, then check at each spawn interval.
# Passing false to both timers freezes their countdowns during pause.
func _ready() -> void:
	await get_tree().create_timer(spawn_delay, false).timeout
	while(is_inside_tree()):
		# The ship removes itself on death, which ends spawning for this run.
		if not is_instance_valid(get_node_or_null("Ship")):
			return
		# Spawn at most one asteroid per check and only below the active cap.
		var asteroid_count := get_tree().get_nodes_in_group("asteroids").size()
		
		if asteroid_count < max_asteroids:
			spawn_asteroid()
		await get_tree().create_timer(spawn_interval, false).timeout
	
	
# Choose a point in the opposite screen quadrant based on the ship's position.
func spawn_asteroid() -> void:
	var screen_size := get_viewport_rect().size
	var ship_position: Vector2 = $Ship.position
	
	var spawn_position := Vector2(
		screen_size.x * 0.75 if ship_position.x < screen_size.x * 0.5
		else screen_size.x * 0.25,
		screen_size.y * 0.75 if ship_position.y < screen_size.y * 0.5
		else screen_size.y * 0.25
	)
	
	
	# Set the size before add_child() runs the asteroid's _ready(), which uses
	# the size to calculate its collision radius and starting health.
	var asteroid = asteroid_scene.instantiate()
	asteroid.size_multiplier = randf_range(0.5, 2.0)
	asteroid.position = spawn_position
	# Put the asteroid on layer 2 and let it collide with layers 1 and 2.
	# The group lets the spawner count asteroids and the ship identify them.
	asteroid.collision_layer = 2
	asteroid.collision_mask = 3
	asteroid.add_to_group("asteroids")
	
	
	asteroid.gold_awarded.connect(_on_gold_awarded)
	
	add_child(asteroid)
