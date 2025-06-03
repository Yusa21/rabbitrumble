extends Resource
##Modelo para las Stages
class_name StageData

@export var id: String = "0" ##Id de la Stage se usa para identificarla en el codigo
@export var name: String = "Default" ##Nombre de la mision
@export var number: int = 0 ##Numero de la mision
@export var difficulty: int = 1 ##Dificultad de la mision
@export var description: String = "Lorem ipsum dolor" ##Descripcion de la mision
@export var enemies: Array[String] = ["testDummy","testDummy","testDummy","testDummy"] ##Id de los enemigos que componen las mision
@export var char_unlocks: Array[String] = [""] ##Id de los personajes que se desbloquean al completar la mision
@export var stage_unlocks: Array[String] = [""] ##Id de las stages que se desbloquean al completar la mision

##Devuelve el id de la stage, se usa para compararlos a la hora de cargarla
func get_id():
    return id