extends Area2D

@export var lifetime: float = 1.1

var velocity: Vector2 = Vector2.ZERO
var time_alive: float = 0.0

func _draw() -> void:
	draw_circle(Vector2.ZERO, 3.0, Color.WHITE)
	
func _physics_process(delta: float) -> void:
	position += velocity * delta
	
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()
