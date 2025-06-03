extends Node
##Repositorio para acceder a las misiones

## Preload de todas las misiones del juego
var stage_collection: StageCollection = preload("res://resources/stage_collection.tres")

## Devuelve el Stage data segun el id 
## [param id] Id del personaje a devolver.
## [return] Stage data con el id del parametro
func load_stage_data_by_id(id: String):
    var stage = stage_collection.get_stage_by_id(id)
    if stage == null:
        push_error("Stage not found: " + id)
    return stage