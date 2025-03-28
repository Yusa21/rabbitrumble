extends "res://scenes/characters/base_character.gd"
class_name EnemyCharacter

#Este tipo de clase siempre tiene que ser enemiga
const alignment = "enemy"

func start_turn():
	print("Enemy turn started with id: " + str(id) + " in position " + str(char_position))
	print("With team " + str(ally_team))
