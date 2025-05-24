extends Node
class_name CharacterRepository

# Preload the collection resource (you'll create this as character_collection.tres)
var character_collection: CharacterCollection = preload("res://resources/character_collection.tres")

func _ready() -> void:
    print("CharacterRepository singleton loaded with %d characters" % character_collection.characters.size())

# Returns the character data by ID, or null if not found
func load_character_data_by_id(id: String) -> CharacterData:
    var character = character_collection.get_character_by_id(id)
    if character == null:
        push_error("Character resource not found: " + id)
    return character

# Get all available character IDs
func get_all_character_ids() -> Array[String]:
    return character_collection.get_all_ids()

# Check if a character exists
func has_character(id: String) -> bool:
    return character_collection.get_character_by_id(id) != null

# Get all characters as array
func get_all_characters() -> Array[CharacterData]:
    return character_collection.characters.duplicate()

