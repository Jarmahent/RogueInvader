extends CanvasLayer


@onready var ship = $"../Ship"
@onready var health_label: Label = $InfoPanel/HealthLabel
@onready var health_bar: ProgressBar = $InfoPanel/HealthBar



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.max_value = ship.max_health
	health_bar.value = ship.health
	health_label.text = "Health: %d / %d" % [ship.health, ship.max_health]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
