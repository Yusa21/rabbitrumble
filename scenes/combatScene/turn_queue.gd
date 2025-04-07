extends Node
class_name TurnQueue
##Clase que maneja el paso de los turnos
##
## Maneja el orden en que los personajes actuan y las fases del turno y las habilidades
var participants
var active_character
var current_index
var current_participant

enum Phase {
	NONE,
	BATTLE_START,
	BATTLE_END,
	ROUND_START,
	ROUND_END,
	PRE_TURN,
	MAIN_TURN,
	POST_TURN
}

signal pre_turn(participant) ##Empieza el turno de alguien
signal main_turn(participant) ##Empieza la parte principal del turno de alguien
signal post_turn(participant) ##Se acaba el turno de alguien
signal round_start ##Empieza una ronda nueva
signal round_end ##Se acaba la ronda actual
signal battle_start ##Empieza la batalla
signal battle_end ##Acaba la batalla

## Incializa la queue con los participantes que son los hijos nodo
func initialize():
	participants = get_children()
	# Ordena los participantes por velocidad
	order_queue()
	process_battle_start()
	emit_signal("battle_start")
	turn_loop()
	process_battle_end()
	emit_signal("battle_end")

##Ordena la lista de turnos segun la velocidad del personaje
func order_queue():
	participants.sort_custom(func(a, b): return a.speed > b.speed)
	
## Reseta el estado de turnos de los participantes
func reset_turns():
	for p in participants:
		p.has_taken_turn = false

## Coge el siguiente participante que todavia no ha hecho su turno
## Si todo el mundo ya ha hecho su turno reinicia la ronda
func get_next_participant():
	#Comprueba que todo el mundo no haya hecho su turno
	var all_taken_turn = true
	for p in participants:
		if not p.has_taken_turn:
			all_taken_turn = false
			break
	
	# Si todo el mundo ha tomado su turno resetea la ronda
	if all_taken_turn:
		await process_round_end()
		emit_signal("round_end")
		await reset_turns()
		await process_round_start()
		emit_signal("round_start")
	
	# Encuentra el siguiente participante
	var i = 0
	for p in participants:
		if not p.has_taken_turn:
			break
		else:
			i+=1
	return participants[i]

## Bucle de turnos
func turn_loop():
	process_round_start()
	emit_signal("round_start")
	while true:
		current_participant = await get_next_participant()
		if current_participant == null:
			break
		
		active_character = current_participant
		await process_pre_turn(active_character)
		await process_main_turn(active_character)
		await process_post_turn(active_character)
		await get_tree().create_timer(3).timeout
		
'''
Funciones de procesamiento de fases
'''
func process_battle_start():
	await process_phase_abilities("battle_start")
	emit_signal("battle_start")
	return true

func process_battle_end():
	await process_phase_abilities("battle_end")
	emit_signal("battle_end")
	return true

func process_round_start():
	await process_phase_abilities("round_start")
	emit_signal("round_start")
	return true

func process_round_end():
	await process_phase_abilities("round_end")
	emit_signal("round_end")
	return true
	
func process_pre_turn(active_character):
	await process_phase_abilities("pre_turn")
	emit_signal("pre_turn", active_character)
	return true
	
func process_main_turn(active_character):
	await active_character.start_turn()
	emit_signal("main_turn", active_character)
	active_character.has_taken_turn = true
	return true
	
func process_post_turn(active_character):
	await process_phase_abilities("post_turn")
	emit_signal("post_turn", active_character)
	return true
	
func process_phase_abilities(phase_trigger):
	for character in participants:
		var triggered_abilities = character.get_phase_triggered_abilities(phase_trigger)
		for ability in triggered_abilities:
			if character.can_use_ability(ability):
				var targets = character.automatic_targeting(ability)
				if targets.size() > 0:
					character.execute_ability(ability, targets)
	
## Anade un participante nuevo y reordena la lista porque tiene nuevas velocidades de las que encargarse
func add_participant(new_participant):
	participants.append(new_participant)
	order_queue()

## Quita un participante de la lista
func remove_participant(participant_to_remove):
	var index = participants.find(participant_to_remove)
	#Si ha encontrado algo (-1 significa que no ha encontrado nada)
	if index != -1:
		participants.remove_at(index)
		#Si el index del que hemos borrado es menor al actual significa que el personaje actual baja una posicion
		#en la lista
		if index < current_index:
			current_index -= 1
