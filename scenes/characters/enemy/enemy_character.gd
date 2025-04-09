extends "res://scenes/characters/base_character.gd"
class_name EnemyCharacter
##Clase hija para los personajes enemigos, contiene la interaccion con la IA
##
##Todavia esta casi vacia porque, en efecto, no hay IA

##Se usa a la hora de identificar si un personaje es jugador o IA
const enemy_alignment = "enemy"

func _ready():
	set_alignment(enemy_alignment)

func start_turn():
	print("Enemy turn started with id: " + str(id) + " in position " + str(char_position))
	print("With team " + str(ally_team))
