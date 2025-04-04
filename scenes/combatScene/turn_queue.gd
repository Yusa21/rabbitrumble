extends Node
class_name TurnQueue
##Clase que maneja el paso de los turnos 
var participants
var active_character
var current_index

signal turn_started(participant) ##Empieza el turno de alguien
signal turn_ended(participant) ##Se acaba el turno de alguien
signal round_started ##Empieza una ronda nueva
signal round_ended ##Se acaba la ronda actual

## Incializa la queue con los participantes que son los hijos nodo
func initialize():
	participants = get_children()
	# Ordena los participantes por velocidad
	order_queue()
	emit_signal("round_started")
	turn_loop()

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
		reset_turns()
		emit_signal("round_ended")
		emit_signal("round_started")
	
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
	while true:
		var current_participant = get_next_participant()
		if current_participant == null:
			break
		
		active_character = current_participant
		emit_signal("turn_started", active_character)
		
		# Wait for the character to complete their turn
		await active_character.start_turn()
		
		# Mark the character's turn as taken
		active_character.has_taken_turn = true
		emit_signal("turn_ended", active_character)
		
		# Optional: Add a small delay between turns if desired
		await get_tree().create_timer(3).timeout

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
