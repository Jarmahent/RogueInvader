extends CanvasLayer

signal continue_requested
signal upgrade_requested(upgrade_id: String)

const UPGRADE_COST: int = 2

@onready var content = $MarketCenter/MarketPanel/MarketContent
@onready var gold_label: Label = content.get_node("GoldLabel")
@onready var health_button: Button = content.get_node("HealthButton")
@onready var damage_button: Button = content.get_node("DamageButton")
@onready var speed_button: Button = content.get_node("SpeedButton")
@onready var continue_button: Button = content.get_node("ContinueButton")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	
	health_button.text = "+10 Health - %d gold" % UPGRADE_COST
	damage_button.text = "+4 Projectile Damage - %d gold" % UPGRADE_COST
	speed_button.text = "+100 Projectile Speed - %d gold" % UPGRADE_COST
	continue_button.pressed.connect(_on_continue_pressed)
	health_button.pressed.connect(
		_on_upgrade_pressed.bind("health")
	)
	
	damage_button.pressed.connect(
		_on_upgrade_pressed.bind("damage")
	)
	
	speed_button.pressed.connect(
		_on_upgrade_pressed.bind("speed")
	)

func _on_upgrade_pressed(upgrade_id: String) -> void:
	upgrade_requested.emit(upgrade_id)
	
	
func update_gold(total: int) -> void:
	gold_label.text = "Gold: %d" % total
	
	var cannot_afford := total < UPGRADE_COST
	health_button.disabled = cannot_afford
	damage_button.disabled = cannot_afford
	speed_button.disabled = cannot_afford
	
	


func _on_continue_pressed() -> void:
	continue_requested.emit()


func _on_health_button_pressed() -> void:
	pass # Replace with function body.


func _on_damage_button_pressed() -> void:
	pass # Replace with function body.


func _on_speed_button_pressed() -> void:
	pass # Replace with function body.
