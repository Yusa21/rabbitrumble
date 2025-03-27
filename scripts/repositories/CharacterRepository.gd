extends Node
class_name CharacterRepository

const res_ext = ".tres"
const char_res_path = "res://resources/characters/"

#Devuelve la informacion de personaje segun el id
func load_character_data_by_id(id: String) -> CharacterData:
	var path = char_res_path + id + res_ext
	if not FileAccess.file_exists(path):
		print("Character resource not found: " + path)
		return null
	return load(path) as CharacterData
