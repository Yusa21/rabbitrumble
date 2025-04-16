extends "res://scenes/characters/base_character.gd"
class_name PlayerCharacter
##Clase hija para los personajes jugadores, contiene las interacciones con la UI
##
##Todavia esta casi vacia porque, en efecto, no hay UI

##Se usa a la hora de identificar si un personaje es jugador o IA
const player_alignment = "player"

var action_done = false

signal end_turn(PlayerCharacter)

func _ready():
	set_alignment(player_alignment)

'''
Todo lo de manejar input y turnos es provisional, la escena no se encarga de eso es la UI
'''
func start_turn():
	print("Player turn started with id: " + str(id) + " in position " + str(char_position))
	print("With team " + str(ally_team[0].alignment))
	print("Turn started, waiting for player actions")
	
	await end_turn
	
	return true

func emit_end_turn():
	emit_signal("end_turn", self)
	print("Turn player turn ended")
	return true
