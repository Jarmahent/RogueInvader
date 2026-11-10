extends Control


@onready var main_buttons: VBoxContainer = $MenuCenter/MainButtons
@onready var options_buttons: VBoxContainer = $MenuCenter/OptionsButtons



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_buttons.show()
	options_buttons.hide()
	
	if OS.has_feature("web"):
		$MenuCenter/MainButtons/ExitButton.hide()


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")


func _on_options_button_pressed() -> void:
	main_buttons.hide()
	options_buttons.show()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	main_buttons.show()
	options_buttons.hide()


func _on_graphics_button_pressed() -> void:
	pass # Replace with function body.


func _on_audio_button_pressed() -> void:
	pass # Replace with function body.
