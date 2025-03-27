extends "res://scenes/characters/base_character.gd"

func start_turn():
	print("Enemy turn started with id: " + str(id) + " in position " + str(char_position))
