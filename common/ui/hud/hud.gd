# The HUD displays the ship's health and offers a restart after death.
extends CanvasLayer

# Ship is a sibling of the HUD. The label, bar, and button are HUD children.
@onready var ship = $"../Ship"
@onready var health_label: Label = $InfoPanel/HealthLabel
@onready var health_bar: ProgressBar = $InfoPanel/HealthBar
@onready var restart_button: Button = $RestartCenter/RestartButton
@onready var game = get_parent()
@onready var gold_label: Label = $InfoPanel/GoldLabel

# Connect to future health changes and read the current health immediately
# so the display is initialized before the first hit.awaw aawwdwda
func _ready() -> void:
	ship.health_changed.connect(_on_health_changed)
	_on_health_changed(ship.health, ship.max_health)
	restart_button.pressed.connect(_on_restart_pressed)
	
	game.gold_changed.connect(_on_gold_changed)
	_on_gold_changed(game.gold)


# Use the same health values for both the bar and the numeric label.
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
	
	# The final health signal arrives before the ship frees itself.
	restart_button.visible = current_health == 0
	
# Reloading Game creates a fresh ship, HUD, and asteroid spawn loop.
func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	
	
func _on_gold_changed(total: int) -> void:
	gold_label.text = "Gold %d" % [total]
