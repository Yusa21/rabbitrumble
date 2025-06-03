extends Resource
##Modelo que se usar para crear una lista de todos los personajes para que luego poder acceder a ellos en tiempo de ejecuccion
class_name CharacterCollection

##Array para guardar todos los datos de los personajes
@export var characters: Array[CharacterData] = []

##Devuelve el personaje por id
## [param id] Id del personaje a buscar
## [return] EL personaje con el id que se busca o null si no existe
func get_character_by_id(id: String) -> CharacterData:
    for character in characters:
        if character != null:
            if character.has_method("get_id") and character.get_id() == id:
                return character
            elif "id" in character and character.id == id:
                return character
    return null