extends PopupPanel
class_name OptionsMenuPopup

@onready var master_volume_slider = get_node("%MasterVolumeSlider")
@onready var music_volume_slider = get_node("%MusicVolumeSlider")
@onready var sfx_volume_slider = get_node("%SFXVolumeSlider")

# Reference to the GameManager singleton
var game_manager: GameManager

func _ready() -> void:
	# Get reference to the GameManager singleton
	game_manager = get_node("/root/GameManager")
	
	# Connect slider signals to their respective functions
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	sfx_volume_slider.drag_ended.connect(_on_sfx_drag_ended)
	
	# Connect popup about_to_popup signal to update sliders when dialog opens
	about_to_popup.connect(_update_slider_values)
	
	# Set popup to exclusive mode to prevent it from closing when clicking inside it
	# and to keep focus within the popup
	exclusive = true

func show_options_pop_up():
	# Update slider values before showing the popup
	_update_slider_values()
	# Show the popup centered on screen
	popup_centered()

# Method to close the popup explicitly
func close_options_popup():
	hide()

# Update all slider values based on current GameManager settings
func _update_slider_values() -> void:
	master_volume_slider.value = game_manager.get_master_volume_percent()
	music_volume_slider.value = game_manager.get_music_volume_percent()
	sfx_volume_slider.value = game_manager.get_sfx_volume_percent()

# Signal handlers for volume sliders
func _on_master_volume_changed(value: float) -> void:
	game_manager.set_master_volume_percent(value)
	# Prevent input event propagation
	get_viewport().set_input_as_handled()

func _on_music_volume_changed(value: float) -> void:
	game_manager.set_music_volume_percent(value)
	# Prevent input event propagation
	get_viewport().set_input_as_handled()

func _on_sfx_volume_changed(value: float) -> void:
	game_manager.set_sfx_volume_percent(value)
	# Prevent input event propagation
	get_viewport().set_input_as_handled()
	
func _on_sfx_drag_ended(_value) -> void:
	GameManager.play_sfx("res://audio/soundEffects/buzzer.ogg")


func _on_done_button_pressed() -> void:
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	close_options_popup()
