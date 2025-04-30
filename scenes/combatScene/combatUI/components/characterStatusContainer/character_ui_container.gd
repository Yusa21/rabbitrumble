extends Control
class_name CharacterStatusContainer

var event_bus: BattleEventBus
var character_ui_scene = preload("characterStatusUI/character_status_ui.tscn")
var character_ui_elements = {}

func initialize(bus: BattleEventBus, participants: Array):
    event_bus = bus
    
    # Create UI elements for each character
    _create_character_ui_elements(participants)
    
    # Connect to battle-wide events that might affect all status UIs
    event_bus.battle_end.connect(_on_battle_end)

func _create_character_ui_elements(participants):
    # Clear any existing UI elements first
    for ui in character_ui_elements.values():
        ui.queue_free()
    character_ui_elements.clear()
    
    # Create new UI elements for each character
    for character in participants:
        if character != null:
            var ui_instance = character_ui_scene.instantiate()
            add_child(ui_instance)
            
            # Initialize the UI with character data
            ui_instance.initialize(character)
            
            # Store reference
            character_ui_elements[character] = ui_instance
            
            print("Created UI for character: ", character.char_name)

func _on_battle_end(_winner):
    # Optional: Add visual indication that battle has ended
    pass