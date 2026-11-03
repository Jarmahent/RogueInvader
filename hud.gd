extends CanvasLayer

@onready var ship = $"../Ship"
@onready var health_label: Label = $InfoPanel/HealthLabel
@onready var health_bar: ProgressBar = $InfoPanel/HealthBar


func _ready() -> void:
	ship.health_changed.connect(_on_health_changed)
	_on_health_changed(ship.health, ship.max_health)


func _on_health_changed(
	current_health: int,
	maximum_health: int
) -> void:
	health_bar.max_value = maximum_health
	health_bar.value = current_health

	health_label.text = "Health: %d / %d" % [
		current_health,
		maximum_health
	]
