extends HBoxContainer

var event_bus
@onready var character_button = get_node("CharacterButton")
@onready var default_icon = character_button.texture_normal

func _ready() -> void:
	pass

func initialize(bus, char_list):
	event_bus = bus
	
	# First make sure we have our template button
	if !character_button:
		push_error("Character button template not found!")
		return
	
	# Hide the template button, we'll use it as a reference but don't want it visible
	character_button.visible = false
	
	# Clear any existing buttons (except the template)
	for child in get_children():
		if child != character_button:
			child.queue_free()
	
	# Create a button for each character
	for character in char_list:
		var new_button = character_button.duplicate()
		new_button.visible = true
		
		# Set the texture if available
		if character.character_icon != null:
			new_button.texture_normal = character.character_icon
		else:
			new_button.texture_normal = default_icon
		
		# Store character data in the button
		new_button.set_meta("character_data", character)
		
		# Connect button press signal
		new_button.pressed.connect(func(): _emit_enemy_character_clicked(character))
	
		# Add the button to the HBox
		add_child(new_button)

func _on_character_button_pressed() -> void:
	# This is now handled by individual button connections
	pass

# Emit signal with specific character data
func _emit_enemy_character_clicked(character_data):
	event_bus.emit_signal("enemy_character_clicked", character_data)
