extends "res://scenes/combatScene/characters/base_character.gd"
class_name PlayerCharacter
##Clase hija para los personajes jugadores, contiene las interacciones con la UI
##
##Todavia esta casi vacia porque, en efecto, no hay UI

var action_done = false


func _ready():
	set_alignment(BattleConstants.Alignment.PLAYER)

'''
Todo lo de manejar input y turnos es provisional, la escena no se encarga de eso es la UI
'''
func start_turn():
	print("Player turn started with id: " + str(id) + " in position " + str(char_position))
	print("With team " + str(ally_team[0].alignment))
	print("Turn started, waiting for player actions")
	
	await event_bus.end_turn
	
	return true

func emit_end_turn():
	event_bus.emit_signal("end_turn", self)
	print("Turn player turn ended")
	return true
