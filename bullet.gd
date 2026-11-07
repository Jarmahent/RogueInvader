# A bullet moves itself and uses Area2D overlap signals to detect hits.
extends Area2D

# Lifetime is in seconds. The ship supplies velocity when it fires.
@export var lifetime: float = 1.5
@export var damage: int = 10

var velocity: Vector2 = Vector2.ZERO
var time_alive: float = 0.0
var has_hit: bool = false


# Listen for bodies entering the bullet's collision shape.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Draw the bullet centered on its local origin.
func _draw() -> void:
	draw_rect(Rect2(Vector2(-3, -5), Vector2(6, 10)), Color.WHITE)


# Convert velocity to distance for this tick, then remove expired bullets.
# Both movement and lifetime counting stop when gameplay is paused.
func _physics_process(delta: float) -> void:
	position += velocity * delta

	time_alive += delta
	if time_alive >= lifetime:
		queue_free()


# Only bodies with take_damage can consume a shot. Set has_hit before
# dealing damage to guard against another overlap before queue_free runs.
func _on_body_entered(body: Node2D) -> void:
	if has_hit:
		return

	if body.has_method("take_damage"):
		has_hit = true
		body.take_damage(damage)
		queue_free()
