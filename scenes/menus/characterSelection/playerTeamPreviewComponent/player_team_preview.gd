extends HBoxContainer

var event_bus
@onready var character_button = get_node("CharacterButton")
@onready var default_icon = character_button.texture_normal

var selected_characters = []  # Array to keep track of selected character IDs
const MAX_CHARACTERS = 4      # Maximum number of characters allowed

func _ready() -> void:
    # Hide the template button if it exists
    if character_button:
        character_button.visible = false

func initialize(bus):
    event_bus = bus
    # Connect to the right-click signal
    event_bus.character_right_clicked.connect(_on_character_right_clicked)
    event_bus.clear_button_clicked.connect(_on_clear_button_clicked)

# Handle character right-click
func _on_character_right_clicked(char_data):
    # Ensure we have a valid character_id
    var char_id = char_data.character_id
    
    # Check if this character is already selected
    var existing_index = -1
    for i in range(selected_characters.size()):
        if selected_characters[i].character_id == char_id:
            existing_index = i
            break
    
    # If character is already selected, remove it
    if existing_index != -1:
        _remove_character(char_data)
        return
    
    # If not already selected and we're at max capacity, ignore
    if selected_characters.size() >= MAX_CHARACTERS:
        return
    
    # Add the character
    selected_characters.append(char_data)
    add_character_button(char_data)

func _on_clear_button_clicked():
    clear_selection()

# Add a button for the character
func add_character_button(char_data):
    # Ensure we have our template
    if !character_button:
        push_error("Character button template not found!")
        return
    
    # Create a new button
    var new_button = character_button.duplicate()
    new_button.visible = true
    
    # Set the texture if available
    if char_data.character_icon != null:
        new_button.texture_normal = char_data.character_icon
    else:
        new_button.texture_normal = default_icon
    
    # Store character data in the button
    new_button.set_meta("character_data", char_data)
    
    # Connect gui_input to detect right clicks
    new_button.gui_input.connect(func(event):
        if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
            _remove_character(char_data)
    )
    
    # Connect left-click to emit the character_clicked signal
    new_button.pressed.connect(func(): _emit_character_clicked(char_data))
    
    # Add the button to the HBox
    add_child(new_button)

# Remove a character from the selection
func _remove_character(char_data):
    var char_id = char_data.character_id
    
    # Remove from tracking array
    for i in range(selected_characters.size()):
        if selected_characters[i].character_id == char_id:
            selected_characters.remove_at(i)
            break
    
    # Find and remove the button from the UI
    for child in get_children():
        if child != character_button and child.has_meta("character_data"):
            var btn_char_data = child.get_meta("character_data")
            if btn_char_data.character_id == char_id:
                child.queue_free()  # Remove the button from the scene
                break

# Emit character clicked signal
func _emit_character_clicked(char_data):
    event_bus.emit_signal("character_clicked", char_data)

# Clear all selected characters
func clear_selection():
    selected_characters.clear()
    
    # Remove all character buttons except template
    for child in get_children():
        if child != character_button:
            child.queue_free()