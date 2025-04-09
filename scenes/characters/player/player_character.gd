extends "res://scenes/characters/base_character.gd"
class_name PlayerCharacter
##Clase hija para los personajes jugadores, contiene las interacciones con la UI
##
##Todavia esta casi vacia porque, en efecto, no hay UI

##Se usa a la hora de identificar si un personaje es jugador o IA
const player_alignment = "player"

##En caso de que se puedan hacer varias acciones, no esta planeado pero la implementacion provisional lo tiene
const total_actions = 1
signal turn_ended

var actions_completed = 0
var total_actions_this_turn = 0
var turn_active = false
var input_handler_connected = false

func _ready():
	set_alignment(player_alignment)

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
	
	# Connect input handler only for this turn
	connect_input_handler()
	
	# Wait for the turn to end before continuing
	await turn_ended
	
	# Make sure we clean up after turn ends
	disconnect_input_handler()
	
	return true

# Connect input handler when turn starts
func connect_input_handler():
	if not input_handler_connected:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_viewport().set_process_input(false)  # Disable viewport input processing temporarily
		input_handler_connected = true
		# Use process_input instead of _input to get stronger priority
		set_process_input(true)

# Disconnect input handler when turn ends
func disconnect_input_handler():
	if input_handler_connected:
		set_process_input(false)
		get_viewport().set_process_input(true)  # Re-enable viewport input processing
		input_handler_connected = false
		turn_active = false

func _input(event):
	# Only process input if turn is active and it's a key press event
	if !turn_active || !input_handler_connected:
		return
		
	if event is InputEventKey and event.pressed:
		# Consume the input event to prevent it from propagating
		get_viewport().set_input_as_handled()
		
		match event.keycode:
			KEY_1:
				if actions_completed < total_actions_this_turn:
					call_deferred("perform_action_1")
			KEY_2:
				if actions_completed < total_actions_this_turn:
					call_deferred("perform_action_2")
			KEY_3:
				if actions_completed < total_actions_this_turn:
					call_deferred("perform_action_3")

func perform_action_1():
	# Safety check in case action is triggered outside of turn
	if !turn_active || actions_completed >= total_actions_this_turn:
		return
		
	print("Action 1 triggered")
	print("Activated action:" + str(abilities[1].name))
	print("Choose target position 1")
	print("Targetting type: " + abilities[1].target_type)
	disconnect_input_handler()  # Disable input during ability execution
	await execute_ability(abilities[1], [1,2,3,4])
	complete_action()

func perform_action_2():
	# Safety check in case action is triggered outside of turn
	if !turn_active || actions_completed >= total_actions_this_turn:
		return
		
	print("Action 2 triggered")
	# Perform your action logic here
	complete_action()

func perform_action_3():
	# Safety check in case action is triggered outside of turn
	if !turn_active || actions_completed >= total_actions_this_turn:
		return
		
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

# Clean up when node is removed
func _exit_tree():
	disconnect_input_handler()
