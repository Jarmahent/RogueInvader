# The Game scene runs the asteroid spawn loop for the current run.
extends Node2D


@onready var market = $Market

signal gold_changed(total: int)
signal stage_progress_changed(current: int, target: int)
signal stage_completed(stage_number: int)


# The Inspector supplies the asteroid scene and sets the timing and cap.
@export var asteroid_scene: PackedScene
@export var spawn_delay: float = 1.0
@export var max_asteroids: int = 5
@export var spawn_interval: float = 2.0


var gold: int = 0
var asteroids_destroyed: int = 0
var stage_targets: Array[int] = [5, 30, 45, 100, 150]
var stage_index: int = 0
var stage_kills: int = 0
var stage_active: bool = true

func _on_gold_awarded(amount: int) -> void:
	var ship := get_node_or_null("Ship")
	if ship == null or ship.is_queued_for_deletion():
		return
	gold += amount
	gold_changed.emit(gold)
	print("Gold +%d | Total: %d" % [amount, gold])

func _on_asteroid_destroyed()-> void:
	asteroids_destroyed+=1
	
	if not stage_active:
		return
	
	stage_kills += 1
	var target := stage_targets[stage_index]
	stage_progress_changed.emit(stage_kills, target)
	
	print(
		"Stage %d: %d / %d"
		% [stage_index + 1, stage_kills, target]
	)
	
	if stage_kills >= target:
		stage_active = false
		_open_market.call_deferred()

# Wait before the first spawn, then check at each spawn interval.
# Passing false to both timers freezes their countdowns during pause.
func _ready() -> void:
	market.upgrade_requested.connect(_on_upgrade_requested)
	gold_changed.connect(market.update_gold)
	market.update_gold(gold)
	market.continue_requested.connect(_on_market_continue_requested)
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
	
func _open_market() -> void:
	stage_completed.emit(stage_index + 1)
	$PauseMenu.market_open = true
	get_tree().paused = true
	market.show()

func _on_upgrade_requested(upgrade_id: String) -> void:
	if stage_active or not market.visible:
		return
		
	if gold < market.UPGRADE_COST:
		return
		
	var ship := get_node_or_null("Ship")
	if ship == null or ship.is_queued_for_deletion():
		return
		
	match upgrade_id:
		"health":
			ship.upgrade_health(10)
		"damage":
			ship.bullet_damage += 4
		"speed":
			ship.bullet_speed += 100
		_:
			return
	
	gold -= market.UPGRADE_COST
	gold_changed.emit(gold)
	
	print(
		"Purchased %s | Gold: %d | Health: %d/%d | Damage: %d | Speed: %.0f"
		% [
			upgrade_id,
			gold,
			ship.health,
			ship.max_health,
			ship.bullet_damage,
			ship.bullet_speed
		]
	)

func get_camera_world_rect() -> Rect2:
	var screen_to_world := get_canvas_transform().affine_inverse()
	return screen_to_world * get_viewport_rect()



func _on_market_continue_requested() -> void:
	if stage_index + 1 >= stage_targets.size():
		print("GAME COMPLETE!")
		return
		
	stage_index += 1
	stage_kills = 0
	stage_active = true
	stage_progress_changed.emit(
		stage_kills,
		stage_targets[stage_index]
	)
	
	market.hide()
	$PauseMenu.market_open = false
	get_tree().paused = false

# Choose a point in the opposite screen quadrant based on the ship's position.
func spawn_asteroid() -> void:
	var ship := get_node_or_null("Ship")
	if ship == null or ship.is_queued_for_deletion():
		return
	
	var size_multiplier := randf_range(0.5, 2.0)
	var asteroid_radius := 30.0 * size_multiplier
	
	var spawn_rect := get_camera_world_rect().grow(
		-asteroid_radius - 20.0
	)
	
	if spawn_rect.size.x <= 0.0 or spawn_rect.size.y <= 0.0:
		return
		
	var spawn_position := Vector2.ZERO
	var found_position := false
	
	for attempt in range(20):
		var candidate := Vector2(
			randf_range(spawn_rect.position.x, spawn_rect.end.x),
			randf_range(spawn_rect.position.y, spawn_rect.end.y)
		)
		
		if candidate.distance_to(ship.global_position) >= (
			180.0 + asteroid_radius
		):
			spawn_position = candidate
			found_position = true
			break
		
	if not found_position:
		return
	
	var asteroid = asteroid_scene.instantiate()
	asteroid.size_multiplier = size_multiplier
	
	asteroid.position = to_local(spawn_position)
	asteroid.collision_layer = 2
	asteroid.collision_mask = 3
	asteroid.add_to_group("asteroids")
	
	asteroid.gold_awarded.connect(_on_gold_awarded)
	asteroid.destroyed.connect(_on_asteroid_destroyed)
	
	add_child(asteroid)
	
	
	
	
	
	
	
