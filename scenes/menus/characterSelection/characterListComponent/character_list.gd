extends GridContainer

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
		
		# Connect left-click (normal press) signal
		new_button.pressed.connect(func(): _emit_character_clicked(character))
		
		# Connect input event signal for right-click detection
		new_button.gui_input.connect(func(event): _on_button_gui_input(event, character))

		bus.character_added_to_team.connect(func(char_id): set_character_grayscale(char_id, true))
		bus.character_removed_from_team.connect(func(char_id): set_character_grayscale(char_id, false))

		
		# Add the button to the grid
		add_child(new_button)

func _on_character_button_pressed() -> void:
	# This is now handled by individual button connections
	pass

func _on_button_gui_input(event, character_data):
	# Right-click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_emit_character_right_clicked(character_data)

	# Double-click (left mouse button)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		_emit_character_right_clicked(character_data)

# Emit signal for left-click
func _emit_character_clicked(character_data):
	event_bus.emit_signal("character_clicked", character_data)

# Emit signal for right-click
func _emit_character_right_clicked(character_data):
	event_bus.emit_signal("character_right_clicked", character_data)

func set_character_grayscale(character_id: String, grayscale: bool) -> void:
	for child in get_children():
		if child == character_button:
			continue
		if child.has_meta("character_data"):
			var data = child.get_meta("character_data")
			if data.character_id == character_id:
				if grayscale:
					child.modulate = Color(0.5, 0.5, 0.5)  # Greyscale
				else:
					child.modulate = Color(1, 1, 1)  # Normal
				break
