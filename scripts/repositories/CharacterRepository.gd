extends Node
##Repositorio para acceder a los personajes
class_name CharacterRepository

##Preload de las coleccion de todas los personajes
var character_collection: CharacterCollection = preload("res://resources/character_collection.tres")

## Returns the Character data by ID, or null if not found
## [param id] Id de la mision a devolver.
## [return] Character data del personaje con el id del parametro
func load_character_data_by_id(id: String) -> CharacterData:
    var character = character_collection.get_character_by_id(id)
    if character == null:
        push_error("Character resource not found: " + id)
    return character