extends "res://scenes/characters/base_character.gd"

func start_turn():
	print("Player turn started with id: " + str(id) + " in position " + str(char_position))
	await get_tree().create_timer(0.1).timeout
	print("Input received, continuing turn")

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_1:
				# Perform action 1
					print("Action 1 triggered")
				
