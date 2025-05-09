extends Control
class_name CharacterUIManagerComponent

# Reference to the character UI scene
var character_ui_scene = preload("res://scenes/combatUI/character_status_ui.tscn")

# Dictionary to store character UI elements
var character_ui_elements = {}

# Event bus reference
var battle_bus

# Initialize the component with the event bus and participants
func initialize(bus, initial_participants):
    battle_bus = bus
    
    # Connect to bus signals that might require UI updates
    battle_bus.battle_start.connect(_on_battle_start)
    battle_bus.battle_end.connect(_on_battle_end)
    
    # Initial creation of UI elements for all participants
    _create_character_ui_elements(initial_participants)
    
    # Optional: Connect to signals for adding/removing characters if your game allows it
    # battle_bus.character_added.connect(_on_character_added)
    # battle_bus.character_removed.connect(_on_character_removed)

# Create UI elements for all characters
func _create_character_ui_elements(participants):
    # Clear any existing UI elements first
    for ui in character_ui_elements.values():
        ui.queue_free()
    character_ui_elements.clear()

    for character in participants:
        if character != null:
            var ui_instance = character_ui_scene.instantiate()
            character_ui_container.add_child(ui_instance)
            ui_instance.initialize(character, battle_bus)
            character_ui_elements[character] = ui_instance
            print("Created UI for character: ", character.char_name)

# Handle battle start event
func _on_battle_start():
    # Any updates needed when battle starts
    _update_all_ui_elements()

# Handle battle end event
func _on_battle_end(_winner):
    # Any cleanup or visual updates needed when battle ends
    pass

# Update all UI elements - can be called after global effects
func _update_all_ui_elements():
    for character, ui in character_ui_elements.items():
        if is_instance_valid(character) and is_instance_valid(ui):
            # Refresh the UI with current character data
            ui.update_health_bar(character.current_hp, character.max_hp)
            # Any other updates that might be needed

# Optional: Handle adding a new character during battle
func _on_character_added(character):
    if character != null and not character_ui_elements.has(character):
        var ui_instance = character_ui_scene.instantiate()
        character_ui_container.add_child(ui_instance)
        ui_instance.initialize(character, battle_bus)
        character_ui_elements[character] = ui_instance
        print("Added UI for new character: ", character.char_name)

# Optional: Handle removing a character during battle
func _on_character_removed(character):
    if character_ui_elements.has(character):
        var ui = character_ui_elements[character]
        ui.queue_free()
        character_ui_elements.erase(character)
        print("Removed UI for character: ", character.char_name)

# Public method to get UI element for a specific character
func get_ui_for_character(character):
    return character_ui_elements.get(character, null)