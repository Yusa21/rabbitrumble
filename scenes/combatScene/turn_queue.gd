extends Node
class_name TurnQueue
##Clase que maneja el paso de los turnos
##
## Maneja el orden en que los personajes actuan y las fases del turno y las habilidades
const GLOBAL_TRIGGERS = ["battle_start", "battle_end", "round_start", "round_end"]
const TURN_TRIGGERS = ["pre_turn", "main_turn", "post_turn"]

var participants
var active_character
var current_index
var current_participant

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
	await process_battle_start()
	await turn_loop()
	await process_battle_end()

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
		await reset_turns()
		await process_round_start()
	
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
	await process_round_start()
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
	
# Update process_phase_abilities function
func process_phase_abilities(phase_trigger):
	# For global triggers (round/battle related), active_character is irrelevant
	var is_global_trigger = GLOBAL_TRIGGERS.has(phase_trigger)
	
	for character in participants:
		var triggered_abilities = character.get_phase_triggered_abilities(phase_trigger)
		print("looking for:" + phase_trigger + " for character : " + str(character.id) + " found ")
		print(triggered_abilities)
		for ability in triggered_abilities:
			if character.can_use_ability(ability):
				# If it's a global trigger, ignore turn-related checks
				# If it's a turn trigger, check whose turn it is
				if is_global_trigger || should_ability_trigger(ability, character, active_character):
					var targets = character.automatic_targeting(ability)
					if targets.size() > 0:
						await character.execute_ability(ability, targets)
	
# Simplified should_ability_trigger function - only used for turn-related triggers
func should_ability_trigger(ability, character, active_character):
	# If it's the character's own turn
	if character == active_character && ability.trigger_on_self_turn:
		return true
	# If it's an ally's turn
	if character != active_character && is_ally(character, active_character) && ability.trigger_on_ally_turn:
		return true
		# If it's an enemy's turn
	if character != active_character && !is_ally(character, active_character) && ability.trigger_on_enemy_turn:
		return true
	# If none of the turn trigger conditions are specified, don't trigger by default for turn triggers	
	return false
# Helper function to check if two characters are allies

func is_ally(character1, character2):
	# You'll need to implement this based on your game's team system
	# For example, checking if they're in the same ally_team array
	return character1.ally_team.has(character2) && character2.ally_team.has(character1)
	
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
