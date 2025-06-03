extends Node
class_name BattleManager

## Gestor principal del sistema de batalla que controla el flujo de estados
## y coordina las acciones entre equipos de personajes.

## Definiciones de estados de batalla
enum BattleState {
	## Estado inicial de la batalla
	INIT,
	## Inicio de una nueva ronda
	ROUND_START,
	## Fase previa al turno de un personaje
	PRE_TURN,
	## Fase principal del turno donde el personaje actua
	MAIN_TURN,
	## Fase posterior al turno del personaje
	POST_TURN,
	## Fin de la ronda
	ROUND_END,
	## Un personaje ha sido derrotado
	CHARACTER_DEFEATED,
	## Fin de la batalla
	BATTLE_END
}

## Referencia al bus de eventos de batalla
var event_bus: BattleEventBus

## Estado actual de la batalla
var current_state: BattleState = BattleState.INIT

## Informacion de la batalla
## Equipo del jugador
var player_team = []
## Equipo enemigo
var enemy_team = []
## Lista completa de participantes en la batalla
var participants = []
## Personaje que tiene el turno activo
var active_character = null
## Cola de personajes derrotados pendientes de procesar
var defeat_queue = []

## Sistema de seguimiento de dano
## Contador de respuestas de dano pendientes
var pending_damage_responses = 0

## Constantes para tipos de disparadores
## Disparadores globales que afectan a toda la batalla
const GLOBAL_TRIGGERS = ["battle_start", "battle_end", "round_start", "round_end"]
## Disparadores relacionados con turnos individuales
const TURN_TRIGGERS = ["pre_turn", "main_turn", "post_turn"]

## Inicializa la batalla con los equipos y el bus de eventos
## [param p_team] Array con los personajes del equipo del jugador
## [param e_team] Array con los personajes del equipo enemigo  
## [param bus] Referencia al bus de eventos de batalla
func initialize(p_team: Array, e_team: Array, bus: BattleEventBus):
	event_bus = bus
	player_team = p_team
	enemy_team = e_team
	participants = player_team + enemy_team
	
	# Configurar referencias de equipo para cada personaje
	for player in player_team:
		player.ally_team = player_team
		player.opps_team = enemy_team
		player.update_position()
	
	for enemy in enemy_team:
		enemy.ally_team = enemy_team
		enemy.opps_team = player_team
		enemy.update_position()
	
	# Conectar senales para derrota de personajes y supervivencia
	event_bus.character_defeated.connect(_on_character_defeated)
	event_bus.still_alive.connect(_on_character_still_alive)
	
	# Ordenar participantes por velocidad
	participants.sort_custom(func(a, b): return a.speed > b.speed)
	
	await event_bus.ui_initialized
	# Iniciar la batalla
	change_state(BattleState.INIT)

## Cambia el estado de batalla con las transiciones apropiadas
## [param new_state] El nuevo estado al que transicionar
func change_state(new_state: BattleState):
	var old_state = current_state
	current_state = new_state
	
	# Emitir evento de cambio de estado via bus
	if event_bus:
		event_bus.emit_signal("state_changed", old_state, new_state)
	
	# Emitir las senales apropiadas basadas en el estado
	match new_state:
		BattleState.INIT:
			if event_bus:
				event_bus.emit_signal("battle_start")
		BattleState.ROUND_START:
			if event_bus:
				event_bus.emit_signal("round_start")
		BattleState.PRE_TURN:
			if event_bus:
				event_bus.emit_signal("pre_turn", active_character)
		BattleState.MAIN_TURN:
			if event_bus:
				event_bus.emit_signal("main_turn", active_character)
		BattleState.POST_TURN:
			if event_bus:
				event_bus.emit_signal("post_turn", active_character)
		BattleState.ROUND_END:
			if event_bus:
				event_bus.emit_signal("round_end")
	
	# Procesar el nuevo estado
	match new_state:
		BattleState.INIT:
			await process_init_state()
		BattleState.ROUND_START:
			await process_round_start()
		BattleState.PRE_TURN:
			await process_pre_turn()
		BattleState.MAIN_TURN:
			await process_main_turn()
		BattleState.POST_TURN:
			await process_post_turn()
		BattleState.ROUND_END:
			await process_round_end()
		BattleState.CHARACTER_DEFEATED:
			await process_character_defeated()
		BattleState.BATTLE_END:
			await process_battle_end()

## Funciones de procesamiento de estados

## Procesa el estado inicial de la batalla
func process_init_state():
	change_state(BattleState.ROUND_START)

## Procesa el inicio de una nueva ronda
func process_round_start():
	# Reiniciar estado de turnos
	for p in participants:
		p.has_taken_turn = false
	
	# Disparar habilidades de inicio de ronda
	await process_phase_abilities("round_start")
	
	# Mover al pre-turno del primer personaje
	active_character = get_next_active_character()
	if active_character != null:
		change_state(BattleState.PRE_TURN)
	else:
		# No hay personajes activos - la batalla debe haber terminado
		change_state(BattleState.BATTLE_END)

## Procesa la fase previa al turno del personaje activo
func process_pre_turn():
	print(str(active_character.char_name) + "'s turn (pre)")
	await process_phase_abilities("pre_turn")
	change_state(BattleState.MAIN_TURN)

## Procesa la fase principal del turno donde el personaje ejecuta sus acciones
func process_main_turn():
	print(str(active_character.char_name) + "'s turn (main)")
	active_character.has_taken_turn = true
	await active_character.start_turn()
	
	# Pequena pausa para asegurar que todas las senales de dano se procesen
	await get_tree().create_timer(2).timeout

	# Esperar a que se resuelvan las respuestas de dano pendientes antes de continuar
	if pending_damage_responses > 0:
		print("Waiting for " + str(pending_damage_responses) + " damage responses to resolve...")
		await event_bus.all_damage_resolved
	
	change_state(BattleState.POST_TURN)

## Procesa la fase posterior al turno del personaje
func process_post_turn():
	print(str(active_character.char_name) + "'s turn (post)")
	await process_phase_abilities("post_turn")
	
	# Verificar derrotas pendientes
	if defeat_queue.size() > 0:
		change_state(BattleState.CHARACTER_DEFEATED)
	else:
		# Encontrar siguiente personaje
		active_character = get_next_active_character()
		if active_character != null:
			change_state(BattleState.PRE_TURN)
		else:
			change_state(BattleState.ROUND_END)

## Procesa el final de la ronda
func process_round_end():
	await process_phase_abilities("round_end")
	
	# Verificar si la batalla debe terminar
	if check_team_defeat():
		change_state(BattleState.BATTLE_END)
	else:
		change_state(BattleState.ROUND_START)

## Procesa la derrota de personajes en la cola de derrotas
func process_character_defeated():
	while defeat_queue.size() > 0:
		var defeated = defeat_queue.pop_front()
		
		# Remover de los equipos apropiados y lista de participantes
		if defeated in player_team:
			player_team.erase(defeated)
		if defeated in enemy_team:
			enemy_team.erase(defeated)
		if defeated in participants:
			participants.erase(defeated)
	
	# Verificar si la batalla debe terminar
	if check_team_defeat():
		change_state(BattleState.BATTLE_END)
	else:
		# Continuar con la secuencia de turnos
		active_character = get_next_active_character()
		if active_character != null:
			change_state(BattleState.PRE_TURN)
		else:
			change_state(BattleState.ROUND_END)

## Procesa el final de la batalla y determina el ganador
func process_battle_end():
	var winner = ""
	if player_team.size() > 0:
		winner = "player"
	else:
		winner = "enemy"
	
	print("Battle ended! Winner: " + winner)
	await process_phase_abilities("battle_end")
	
	if event_bus:
		event_bus.emit_signal("battle_end", winner)

## Procesa las habilidades que se activan en fases especificas
## [param phase_trigger] El tipo de fase que dispara las habilidades
func process_phase_abilities(phase_trigger):
	# Para disparadores globales (relacionados con ronda/batalla)
	var is_global_trigger = GLOBAL_TRIGGERS.has(phase_trigger)
	
	# Procesar disparadores para todos los personajes
	for character in participants:
		# Verificar objetos nulos
		if character == null:
			push_error("Warning: Found null character in participants array")
			continue
			
		# Verificacion de seguridad para existencia de metodo
		if not character.has_method("get_phase_triggered_abilities"):
			push_error("Warning: Character " + str(character) + " doesn't have get_phase_triggered_abilities method")
			continue
			
		var triggered_abilities = character.get_phase_triggered_abilities(phase_trigger)
		
		for ability in triggered_abilities:
			# Verificacion de nulo para habilidad
			if ability == null:
				push_error("Warning: Null ability found for character " + str(character.char_name))
				continue
				
			if character.can_use_ability(ability):
				# Verificar si la habilidad debe activarse basado en de quien es el turno
				if is_global_trigger || should_ability_trigger(ability, character, active_character):
					var targets = character.automatic_targeting(ability)
					if targets.size() > 0:
						await character.execute_ability(ability, targets)
						
						# Esperar respuestas de dano pendientes despues de ejecutar habilidad
						if pending_damage_responses > 0:
							await event_bus.all_damage_resolved

## Funciones de seguimiento de dano

## Incrementa el contador de respuestas de dano pendientes
func increment_pending_damage():
	pending_damage_responses += 1
	print("Pending damage responses: " + str(pending_damage_responses))

## Decrementa el contador de respuestas de dano pendientes
func decrement_pending_damage():
	pending_damage_responses -= 1
	print("Pending damage responses: " + str(pending_damage_responses))
	if pending_damage_responses <= 0:
		pending_damage_responses = 0
		event_bus.emit_signal("all_damage_resolved")

## Funciones auxiliares

## Obtiene el siguiente personaje activo que no ha tomado su turno
## [return] El siguiente personaje activo o null si no hay ninguno
func get_next_active_character():
	# Encontrar siguiente personaje que no ha tomado turno aun
	for p in participants:
		# Verificacion de nulo
		if p == null:
			continue
			
		if !p.has_taken_turn and !p.is_defeated:
			return p
	return null

## Verifica si alguno de los equipos ha sido completamente derrotado
## [return] true si un equipo ha sido derrotado, false en caso contrario
func check_team_defeat():
	# Verificar si el equipo del jugador fue derrotado
	if player_team.size() == 0:
		return true
	
	# Verificar si el equipo enemigo fue derrotado
	if enemy_team.size() == 0:
		return true
	
	return false

## Determina si una habilidad debe activarse basado en las relaciones entre personajes
## [param ability] La habilidad a evaluar
## [param character] El personaje que posee la habilidad
## [param active_char] El personaje que tiene el turno activo
## [return] true si la habilidad debe activarse, false en caso contrario
func should_ability_trigger(ability, character, active_char):
	# Verificacion de nulo para active_char
	if active_char == null:
		return false
		
	# Si es el turno del propio personaje
	if character == active_char && ability.trigger_on_self_turn:
		return true
		
	# Si es el turno de un aliado
	if character != active_char && is_ally(character, active_char) && ability.trigger_on_ally_turn:
		return true
		
	# Si es el turno de un enemigo
	if character != active_char && !is_ally(character, active_char) && ability.trigger_on_enemy_turn:
		return true
		
	# Si ninguna de las condiciones de disparo de turno esta especificada, no activar por defecto
	return false

## Funcion auxiliar para verificar si dos personajes son aliados
## [param character1] Primer personaje a comparar
## [param character2] Segundo personaje a comparar
## [return] true si son aliados, false en caso contrario
func is_ally(character1, character2):
	# Verificaciones de nulo
	if character1 == null or character2 == null:
		return false
	if not character1.has_method("ally_team") or not character2.has_method("ally_team"):
		return false
		
	return character1.ally_team.has(character2) && character2.ally_team.has(character1)

## Manejadores de senales para respuestas de dano de personajes

## Maneja la senal cuando un personaje es derrotado
## [param character] El personaje que fue derrotado
func _on_character_defeated(character):
	print(str(character.char_name) + " signal defeated")
	# Anadir a la cola de derrotas para procesar en el momento apropiado
	if !defeat_queue.has(character):
		defeat_queue.append(character)
	
	# Decrementar contador de respuestas de dano pendientes
	decrement_pending_damage()

## Maneja la senal cuando un personaje sobrevive al dano
## [param character] El personaje que sigue vivo
func _on_character_still_alive(character):
	print(str(character.char_name) + " signal still alive")
	# Decrementar contador de respuestas de dano pendientes
	decrement_pending_damage()