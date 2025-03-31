extends "res://scenes/characters/base_character.gd"
class_name PlayerCharacter

#Este tipo de clase siempre es del jugador
const alignment = "player"

const total_actions = 1
signal turn_ended

var actions_completed = 0
var total_actions_this_turn = 0
var turn_active = false
'''
Todo lo de manejar input y turnos es provisional, la escena no se encarga de eso es la UI
'''
func start_turn():
	print("Player turn started with id: " + str(id) + " in position " + str(char_position))
	print("With team " + str(ally_team[0].alignment))
	print("Turn started, waiting for player actions")
	actions_completed = 0
	total_actions_this_turn = total_actions
	turn_active = true
	
	# Wait a brief moment to ensure everything is ready
	await get_tree().create_timer(0.1).timeout
	
	# Wait for the turn to end before continuing
	await turn_ended

func _input(event):
	# Only process input if turn is active and it's a key press event
	if turn_active and event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				if actions_completed < total_actions_this_turn:
					perform_action_1()
			KEY_2:
				if actions_completed < total_actions_this_turn:
					perform_action_2()
			KEY_3:
				if actions_completed < total_actions_this_turn:
					perform_action_3()

func perform_action_1():
	print("Action 1 triggered")
	print("Activated action:" + str(abilities[1].name))
	print("Choose target position 1")
	print("Targetting type: " + abilities[1].target_type)
	await execute_ability(abilities[1], [1])
	complete_action()

func perform_action_2():
	print("Action 2 triggered")
	# Perform your action logic here
	complete_action()

func perform_action_3():
	print("Pass turn")
	# Perform your action logic here
	complete_action()

func complete_action():
	actions_completed += 1
	
	# Check if all actions for this turn are completed
	if actions_completed >= total_actions_this_turn:
		end_turn()
		
func chosen_targets():
	print("targets chosen")
	emit_signal("execute_action")

func end_turn():
	print("Turn ended")
	turn_active = false
	emit_signal("turn_ended")
