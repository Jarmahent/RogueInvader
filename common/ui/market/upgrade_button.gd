class_name UpgradeButton
extends Button

signal upgrade_selected(upgrade_id: String)

var upgrade_id: String


func _ready() -> void:
	pressed.connect(_on_pressed)

func configure(id: String, display_text: String) -> void:
	upgrade_id = id
	text = display_text
	
func _on_pressed() -> void:
	upgrade_selected.emit(upgrade_id)
