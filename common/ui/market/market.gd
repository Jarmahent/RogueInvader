extends CanvasLayer

signal upgrade_requested(upgrade_id: String)

@export_range(1, 20) var choice_count: int = 3

@onready var content = $MarketCenter/MarketPanel/MarketContent
@onready var upgrade_choices = content.get_node("UpgradeChoices")

var upgrade_pool: Array[Dictionary] = [
	{"id": "health", "text": "+ Maximum Health"},
	{"id": "damage", "text": "+ Projectile Damage"},
	{"id": "speed", "text": "+ Projectile Speed"},
	{"id": "max_stamina", "text": "+ Max Stamina"}
]


func _ready() -> void:
	hide()
	
	content.get_node("TitleLabel").text = "Level up, choose an upgrade!"
	content.get_node("GoldLabel").hide()
	content.get_node("ContinueButton").hide()

func refresh_choices() -> void:
	for child in upgrade_choices.get_children():
		upgrade_choices.remove_child(child)
		child.queue_free()
	
	var available := upgrade_pool.duplicate()
	available.shuffle()
	
	var amount := mini(choice_count, available.size())
	
	for index in range(amount):
		var upgrade: Dictionary = available[index]
		var button := UpgradeButton.new()
		
		button.configure(upgrade["id"], upgrade["text"])
		button.upgrade_selected.connect(_on_upgrade_selected)
		
		upgrade_choices.add_child(button)
		
func _on_upgrade_selected(upgrade_id: String) -> void:
	upgrade_requested.emit(upgrade_id)

		
