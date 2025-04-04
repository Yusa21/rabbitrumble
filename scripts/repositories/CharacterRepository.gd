extends Node
class_name CharacterRepository
##Repositorio para cargar la informacion de personaje de los recursos .tres


const res_ext = ".tres" ##Extension para los recursos
const char_res_path = "res://resources/characters/" ##Constante que tiene el path a los recursos de personaje

##Devuelve la informacion de personaje segun el id
##Si no encuentra nada devuelve nulo
func load_character_data_by_id(id: String) -> CharacterData:
	var path = char_res_path + id + res_ext
	if not FileAccess.file_exists(path):
		print("Character resource not found: " + path)
		return null
	return load(path) as CharacterData
