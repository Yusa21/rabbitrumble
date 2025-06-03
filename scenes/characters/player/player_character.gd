extends "res://scenes/characters/base_character.gd"
class_name PlayerCharacter
##Clase hija para los personajes jugadores, contiene las interacciones con la UI

##Se usa a la hora de identificar si un personaje es jugador o IA
const player_alignment = "player"

##Variable que maneja si el personaje ya ha hecho su accion
var action_done = false

##[signal end_turn] Senal que marca el final del turno del personaje
signal end_turn(PlayerCharacter)

func _ready():
	set_alignment(player_alignment)
	
##Funcion que se llama desde el battle manager para empezar el turno del personaje
func start_turn():
	await end_turn
	return true

##Funcion que se llama desde la UI cuando el personaje acaba el turno para que continue la ejecucion
func emit_end_turn():
	emit_signal("end_turn", self)
	return true
