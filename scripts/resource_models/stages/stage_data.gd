extends Resource
class_name StageData

@export var id: String = "0"
@export var name: String = "Default"
@export var number: int = 0
@export var difficulty: int = 1
@export var description: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
@export var enemies: Array[String] = ["testDummy","testDummy","testDummy","testDummy"]
@export var char_unlocks: Array[String] = [""] ##Recompensa del la mision, problamente personajes pero todavia no se que ponerle
@export var stage_unlocks: Array[String] = [""]


func get_id():
    return id