extends Area2D

@export var lifetime: float = 1.5
@export var damage: int = 10

var velocity: Vector2 = Vector2.ZERO
var time_alive: float = 0.0
var has_hit: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 3.0, Color.WHITE)


func _physics_process(delta: float) -> void:
	position += velocity * delta

	time_alive += delta
	if time_alive >= lifetime:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if has_hit:
		return

	if body.has_method("take_damage"):
		has_hit = true
		body.take_damage(damage)
		queue_free()
