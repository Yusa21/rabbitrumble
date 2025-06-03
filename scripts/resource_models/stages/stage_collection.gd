extends Resource
##Modelo que se usar para crear una lista de todos los personajes para que luego poder acceder a ellos en tiempo de ejecuccion
class_name StageCollection

##Array de todas las misiones del juego para luego poder acceder a ellas en tiempo de ejecuccion
@export var stages: Array[StageData] = []

##Devuelve la mision por id
## [param id] Id de la mision buscar
## [return] La mision con el id que se busca o null si no existe
func get_stage_by_id(id: String) -> StageData:
    for stage in stages:
        if stage != null:
            if stage.has_method("get_id") and stage.get_id() == id:
                return stage
            elif "id" in stage and stage.id == id:
                return stage
    return null