extends CanvasLayer

signal upgrade_requested(upgrade_id: String)

@onready var content = $MarketCenter/MarketPanel/MarketContent


func _ready() -> void:
	hide()

	content.get_node("TitleLabel").text = "Level up, choose your upgrades!"
	content.get_node("GoldLabel").hide()
	content.get_node("ContinueButton").hide()

	content.get_node("HealthButton").text = "+ Maximum Health"
	content.get_node("DamageButton").text = "+ Projectile Damage"
	content.get_node("SpeedButton").text = "+ Projectile Speed"
	content.get_node("MaxStaminaButton").text = "+ Max Stamina"

func _on_health_button_pressed() -> void:
	upgrade_requested.emit("health")

func _on_damage_button_pressed() -> void:
	upgrade_requested.emit("damage")

func _on_speed_button_pressed() -> void:
	upgrade_requested.emit("speed")
	
func _on_max_stamina_button_pressed() -> void:
	upgrade_requested.emit("max_stamina")
