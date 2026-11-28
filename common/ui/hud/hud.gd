# The HUD displays the ship's health and offers a restart after death.
extends CanvasLayer

# Ship is a sibling of the HUD. The label, bar, and button are HUD children.
@onready var ship = $"../Ship"
@onready var health_label: Label = $InfoPanel/HealthLabel
@onready var health_bar: ProgressBar = $InfoPanel/HealthBar
@onready var restart_button: Button = $RestartCenter/RestartButton
@onready var game = get_parent()
@onready var xp_label: Label = $InfoPanel/XPLabel
@onready var xp_bar: ProgressBar = $InfoPanel/XPBar
@onready var stamina_bar: ProgressBar = $InfoPanel/StaminaBar

# Connect to future health changes and read the current health immediately
# so the display is initialized before the first hit.awaw aawwdwda
func _ready() -> void:
	ship.health_changed.connect(_on_health_changed)
	_on_health_changed(ship.health, ship.max_health)
	restart_button.pressed.connect(_on_restart_pressed)
	
	ship.stamina_changed.connect(_on_stamina_changed)
	stamina_bar.max_value = ship.max_stamina
	_on_stamina_changed(ship.stamina, ship.max_stamina)
	game.xp_changed.connect(_on_xp_changed)
	_on_xp_changed(game.xp, game.xp_to_next_level)


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

func _on_stamina_changed(stamina: float, max_stamina: float) -> void:
	stamina_bar.value = stamina
	stamina_bar.max_value = max_stamina
	
func _on_xp_changed(current: int, target: int) -> void:
	xp_bar.max_value = target
	xp_bar.value = current

	xp_label.text = "Level %d | XP: %d / %d" % [
		game.player_level,
		current,
		target
	]
