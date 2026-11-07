# The scene sets this layer's process mode to Always so its input and buttons
# keep working while the rest of the game is paused.
extends CanvasLayer


# Both button groups are children of the overlay. Showing one group can
# therefore be done independently of the other.
@onready var overlay: CenterContainer = $MenuOverlay
@onready var main_buttons: VBoxContainer = $MenuOverlay/MainButtons
@onready var options_buttons: VBoxContainer = $MenuOverlay/OptionsButtons


# Start with the overlay hidden and the main buttons ready to show.
func _ready() -> void:
	overlay.hide()
	_show_main_menu()
	
	# We dont need to show the exit to desktop button on the web
	if OS.has_feature("web"):
		$MenuOverlay/MainButtons/ExitToDesktop.hide()


# Handle Escape after the UI has had a chance to use the event.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		
		# Escape goes back from Options. On the main screen or during play,
		# it toggles pause.
		if options_buttons.visible and overlay.visible:
			_show_main_menu()
		else:
			_set_paused(not get_tree().paused)
			
			
# Pause the whole scene tree and keep the overlay visibility in sync.
# Reset to the main button group for the next time the menu opens.
func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	overlay.visible = paused
	_show_main_menu()
	
func _show_main_menu() -> void:
	main_buttons.show()
	options_buttons.hide()
	
# The scene connects each working button's pressed signal to its handler.
func _on_resume_pressed() -> void:
	_set_paused(false)
	
# Switch groups while staying paused. The graphics and audio buttons are
# disabled placeholders in the scene.
func _on_options_pressed() -> void:
	main_buttons.hide()
	options_buttons.show()
	
func _on_back_pressed() -> void:
	_show_main_menu()
	
func _on_exit_to_desktop_pressed() -> void:
	get_tree().quit()
