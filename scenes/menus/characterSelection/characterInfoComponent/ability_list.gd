extends HBoxContainer

var event_bus
@onready var ability_button = get_node("AbilityButton")
@onready var default_icon = ability_button.texture_normal

func _ready() -> void:
	pass

func initialize(bus):
	event_bus = bus
	event_bus.character_clicked.connect(_on_character_clicked)

# Transform local signal into bus signal
func _on_ability_button_pressed() -> void:
	# This will be connected dynamically to each button
	pass

# When a character is clicked, load all abilities into the bar
func _on_character_clicked(char_data):
	# Clear existing ability buttons (except the first one)
	for child in get_children():
		if child != ability_button:
			child.queue_free()
	
	# Check if character has abilities
	if not char_data.abilities or char_data.abilities.size() == 0:
		# If no abilities, hide the default button or set it to a disabled state
		ability_button.visible = false
		return
	
	# Process the first ability
	var first_ability = char_data.abilities[0]
	setup_ability_button(ability_button, first_ability)
	ability_button.visible = true
	
	# Create buttons for additional abilities
	for i in range(1, char_data.abilities.size()):
		var ability_data = char_data.abilities[i]
		var new_button = ability_button.duplicate()
		setup_ability_button(new_button, ability_data)
		add_child(new_button)

# Setup button with ability data
func setup_ability_button(button, ability_data):
	# Set button texture
	if ability_data.icon_sprite:
		button.texture_normal = ability_data.icon_sprite
		button.texture_pressed = ability_data.icon_pressed
	else:
		button.texture_normal = default_icon
	
	# Store ability data in the button for reference
	button.set_meta("ability_data", ability_data)
	
	# Connect the pressed signal
	if button.is_connected("pressed", _on_ability_button_pressed):
		button.disconnect("pressed", _on_ability_button_pressed)
	
	# Use a lambda to capture the specific ability_data
	button.pressed.connect(func(): _emit_ability_clicked(ability_data))
	
# Emit signal with specific ability data
func _emit_ability_clicked(ability_data):
	event_bus.emit_signal("ability_clicked", ability_data)
