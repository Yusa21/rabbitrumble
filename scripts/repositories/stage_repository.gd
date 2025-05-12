extends Node
class_name StageRepository
##Repositorio para cargar la informacion de mision de los recursos .tres


const res_ext = ".tres" ##Extension para los recursos
const stage_res_path = "res://resources/stages/" ##Constante que tiene el path a los recursos de mision

##Devuelve la informacion de la mision segun el id
##Si no encuentra nada devuelve nulo
func load_stage_data_by_id(id: String) -> StageData:
	var path = stage_res_path + id + res_ext
	if not FileAccess.file_exists(path):
		print("Stage resource not found: " + path)
		return null
	return load(path) as StageData
