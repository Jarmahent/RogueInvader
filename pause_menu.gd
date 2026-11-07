extends CanvasLayer


@onready var overlay: CenterContainer = $MenuOverlay
@onready var main_buttons: VBoxContainer = $MenuOverlay/MainButtons
@onready var options_buttons: VBoxContainer = $MenuOverlay/OptionsButtons


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	overlay.hide()
	_show_main_menu()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		
		if options_buttons.visible and overlay.visible:
			_show_main_menu()
		else:
			_set_paused(not get_tree().paused)
			
			
func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	overlay.visible = paused
	_show_main_menu()
	
func _show_main_menu() -> void:
	main_buttons.show()
	options_buttons.hide()
	
func _on_resume_pressed() -> void:
	_set_paused(false)
	
func _on_options_pressed() -> void:
	main_buttons.hide()
	options_buttons.show()
	
func _on_back_pressed() -> void:
	_show_main_menu()
	
func _on_exit_to_desktop_pressed() -> void:
	get_tree().quit()
