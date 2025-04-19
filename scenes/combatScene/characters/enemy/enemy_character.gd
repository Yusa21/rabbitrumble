extends "res://scenes/combatScene/characters/base_character.gd"
class_name EnemyCharacter
##Clase hija para los personajes enemigos, contiene la interaccion con la IA
##
##Todavia esta casi vacia porque, en efecto, no hay IA

func _ready():
	set_alignment(BattleConstants.Alignment.ENEMY)

func start_turn():
	print("Enemy turn started with id: " + str(id) + " in position " + str(char_position))
	print("With team " + str(ally_team))
