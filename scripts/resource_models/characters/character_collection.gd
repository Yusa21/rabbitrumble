# CharacterCollection.gd
extends Resource
class_name CharacterCollection

# Array to store all character resources
@export var characters: Array[CharacterData] = []

# Get character by ID (assuming your CharacterData has an id property)
func get_character_by_id(id: String) -> CharacterData:
    for character in characters:
        if character != null:
            # Adjust this based on how your CharacterData stores its ID
            if character.has_method("get_id") and character.get_id() == id:
                return character
            elif "id" in character and character.id == id:
                return character
    return null

# Get all character IDs
func get_all_ids() -> Array[String]:
    var ids: Array[String] = []
    for character in characters:
        if character != null:
            if character.has_method("get_id"):
                ids.append(character.get_id())
            elif "id" in character:
                ids.append(character.id)
    return ids

# Add a new character
func add_character(character_data: CharacterData) -> void:
    characters.append(character_data)

# Remove character by ID
func remove_character_by_id(id: String) -> bool:
    for i in range(characters.size()):
        var character = characters[i]
        if character != null:
            var character_id = ""
            if character.has_method("get_id"):
                character_id = character.get_id()
            elif "id" in character:
                character_id = character.id
            
            if character_id == id:
                characters.remove_at(i)
                return true
    return false