extends Control
## Controlador de interfaz de batalla que maneja la UI durante la batalla.
class_name BattleUIController

## Referencia al gestor de batalla.
var battle_manager: BattleManager
## Personaje actual cuyo turno esta activo.
var current_character = null
## Habilidad seleccionada por el jugador.
var selected_ability = null
## Lista de objetivos seleccionados para la habilidad.
var selected_targets = []
## Modo de seleccion de objetivos activo o no.
var targeting_mode = false

## Escena precargada para los elementos de UI de cada personaje.
var character_ui_scene = preload("charactersUIComponent/character_status_ui.tscn")
## Diccionario que almacena instancias de UI para cada personaje.
var character_ui_elements = {} 

## Referencia al bus de eventos de batalla.
var battle_bus: BattleEventBus

@onready var battle_state_display = get_node("%BattleStateDisplay")
@onready var character_ui_container = get_node("%CharacterUIContainer")
@onready var ability_panel = get_node("%AbilityPanel")
@onready var turn_order_display = get_node("%TurnOrderDisplay")
@onready var options_menu = get_node("%OptionsPopup")
@onready var surrender_menu = get_node("%SurrenderPanel")
@onready var canvas_layer = get_node_or_null("..")

## Llamado cuando el nodo esta listo.
## Configura la UI y habilita el proceso de entrada para cliquer derecho.
func _ready():
	# Impresion de depuracion
	print("BattleUIController ready")
	
	# Configura el manejo de entrada para clic derecho
	set_process_input(true)

## Inicializa el controlador con el gestor de batalla y el bus de eventos.
## [param manager] Instancia de BattleManager.
## [param bus] Instancia de BattleEventBus.
func initialize(manager: BattleManager, bus: BattleEventBus):
	battle_manager = manager
	battle_bus = bus
	print("BattleUIController initialized with battle manager: ", battle_manager)

	# Conecta señales del bus de eventos a los manejadores
	battle_bus.state_changed.connect(_on_battle_state_changed)
	battle_bus.pre_turn.connect(_on_pre_turn)
	battle_bus.main_turn.connect(_on_main_turn)
	battle_bus.post_turn.connect(_on_post_turn)
	battle_bus.battle_end.connect(_on_battle_end)
	battle_bus.character_clicked.connect(_on_character_clicked)
	battle_bus.massive_ability_used.connect(_on_massive_ability_used)
	battle_bus.ability_selected.connect(_handle_ability_selection)
	battle_bus.giving_up.connect(_on_giving_up)

	# Inicializa la visualizacion del orden de turnos con el gestor y el bus
	if turn_order_display:
		turn_order_display.initialize(battle_manager, battle_bus)
	else:
		push_error("Warning: Turn order display not found in scene")
		
	if battle_state_display:
		battle_state_display.initialize(battle_bus)
	else:
		push_error("Warning: Battle state display not found in scene")

	if ability_panel:
		ability_panel.initialize(battle_bus)
	else:
		push_error("Warning: Ability panel not found in scene")

	if surrender_menu:
		surrender_menu.initialize(battle_bus)
	else :
		push_error("Warning: Surrender menu not found in scene")

	print("Initial battle state: ", BattleManager.BattleState.keys()[battle_manager.current_state])
	_force_update_ui_for_current_state()
	_create_character_ui_elements()

	battle_bus.emit_signal("ui_initialized")

## Crea elementos de UI para cada personaje participante en la batalla.
func _create_character_ui_elements():
	# Elimina cualquier elemento de UI existente primero
	for ui in character_ui_elements.values():
		ui.queue_free()
	character_ui_elements.clear()

	for character in battle_manager.participants:
		if character != null:
			var ui_instance = character_ui_scene.instantiate()
			character_ui_container.add_child(ui_instance)
			ui_instance.initialize(character, battle_bus) # <- Pasa el bus
			character_ui_elements[character] = ui_instance
			print("Created UI for character: ", character.char_name)

## Manejador cuando cambia el estado de la batalla.
## [param from_state] Estado anterior.
## [param to_state] Estado nuevo.
func _on_battle_state_changed(from_state, to_state):
	print("Battle state changed: ", BattleManager.BattleState.keys()[from_state], " -> ", BattleManager.BattleState.keys()[to_state])
	
	# Resetea resaltados cuando cambia estado (excepto desde MAIN_TURN si esta en modo de seleccion)
	if from_state != BattleManager.BattleState.MAIN_TURN or not targeting_mode:
		_reset_all_highlights()

## Fuerza la actualizacion de la UI basada en el estado actual de la batalla.
func _force_update_ui_for_current_state():
	var current_state = battle_manager.current_state
	print("Forcing UI update for current state: ", BattleManager.BattleState.keys()[current_state])
	
	match current_state:
		BattleManager.BattleState.INIT:
			pass
		BattleManager.BattleState.ROUND_START:
			pass
		BattleManager.BattleState.PRE_TURN, BattleManager.BattleState.MAIN_TURN, BattleManager.BattleState.POST_TURN:
			if battle_manager.active_character:
				current_character = battle_manager.active_character
				
				# Habilita botones para personaje jugador
				var is_player_turn = current_character.alignment == "player"
				
				if is_player_turn:
					_update_ability_buttons(current_character)

		BattleManager.BattleState.ROUND_END:
			pass
		BattleManager.BattleState.BATTLE_END:
			pass

## Manejador de la señal pre-turno.
## [param character] Personaje que inicia su pre-turno.
func _on_pre_turn(character):
	print("Pre-turn for character: ", character.char_name)
	current_character = character
	
	# Deshabilita botones de habilidad durante turnos de IA
	var is_player_turn = character.alignment == "player"
	
	# Actualiza habilidades disponibles si es personaje jugador
	if is_player_turn:
		_update_ability_buttons(character)
	
	# Resetea seleccion de objetivos
	_cancel_targeting()

## Manejador de la señal main-turn.
## [param character] Personaje que inicia su turno principal.
func _on_main_turn(character):
	print("Main turn for character: ", character.char_name)
	# Para personajes IA, espera a que termine su turno
	if (character.alignment != "player"):
		# Personaje IA - no se necesita entrada del jugador
		pass

## Manejador de la señal post-turno.
## [param character] Personaje que finalizo su turno.
func _on_post_turn(character):
	print("Post turn for character: ", character.char_name)
	# Limpia referencia al personaje actual despues del turno
	_reset_all_highlights()

## Manejador cuando la batalla termina.
## [param winner] Identificador del ganador.
func _on_battle_end(winner):
	print("Battle ended. Winner: ", winner)
	_reset_all_highlights()

## Actualiza los botones de habilidad basandose en el personaje activo.
## [param character] Personaje actual cuyas habilidades se muestran.
func _update_ability_buttons(character):
	var abilities = character.abilities
	print("Updating ability buttons for: ", character.char_name, ", abilities count: ", abilities.size())
	
	# Actualiza boton 1
	if abilities.size() > 0:
		# Comprueba que el personaje este en una posicion donde se pueda usar la habilidad
		if abilities[0].launch_position.has(character.char_position):
			print("Ability 1 enabled: ", abilities[0].name)
		else:
			print("Ability 1 disabled due to position: ", abilities[0].name)
	else:
		print("No ability 1 available")
	
	# Actualiza boton 2
	if abilities.size() > 1:
		# Comprueba que el personaje este en una posicion donde se pueda usar la habilidad
		if abilities[1].launch_position.has(character.char_position):
			print("Ability 2 enabled: ", abilities[1].name)
		else:
			print("Ability 2 disabled due to position: ", abilities[1].name)
	else:
		print("No ability 2 available")
		
## Manejador de seleccion de habilidad.
## [param ability_data] Datos de la habilidad seleccionada.
## [param ability_index] Indice de la habilidad en el arreglo.
func _handle_ability_selection(ability_data, ability_index):
	# Resetea cualquier resaltado previo
	_reset_all_highlights()
	selected_targets.clear()
	
	# Obtiene habilidades del personaje actual
	var abilities = current_character.abilities
	if ability_index < abilities.size():
		selected_ability = ability_data
		print("Selected ability: ", selected_ability.name)
		
		# Entra en modo de seleccion de objetivos
		targeting_mode = true
		
		_highlight_possible_targets(selected_ability)
		
		if selected_ability.target_type == "multiple_opps" or selected_ability.target_type == "multiple_allies":
			_auto_select_all_targets(selected_ability)
			print("Auto-selected targets for multi-target ability: ", selected_targets.size())
			# Espera clic de personaje antes de ejecutar

	else:
		print("No ability at index ", ability_index)
		# Habilidad no necesita objetivos, ejecutar inmediatamente
		_execute_current_ability([])

## Resalta posibles objetivos segun la habilidad seleccionada.
## [param ability] Habilidad actual.
func _highlight_possible_targets(ability):
	print("Highlighting possible targets for ability: ", ability.name)
	var highlight_pos = ability.target_position
	var highlighted_count = 0
	
	if ability.target_type == "single_opp" || ability.target_type == "multiple_opps":
		for opp in current_character.opps_team:
			if opp.char_position in highlight_pos:
				opp.highlight(true)
				highlighted_count += 1
				print("Highlighted opponent: ", opp.char_name, " at position ", opp.char_position)
	elif ability.target_type == "single_ally" || ability.target_type == "multiple_allies":
		for ally in current_character.ally_team:
			if ally.char_position in highlight_pos:
				ally.highlight(true)
				highlighted_count += 1
				print("Highlighted ally: ", ally.char_name, " at position ", ally.char_position)
	elif ability.target_type == "self":
		current_character.highlight(true)
		highlighted_count += 1
		print("Highlighted self: ", current_character.char_name)
		
	print("Total targets highlighted: ", highlighted_count)

## Selecciona automaticamente todos los objetivos validos para habilidades de tipo multiple.
## [param ability] Habilidad actual.
func _auto_select_all_targets(ability):
	selected_targets.clear()
	print("Auto-selecting targets for ", ability.name)
	
	var target_positions = ability.target_position
	
	if ability.target_type == "multiple_opps":
		for opp in current_character.opps_team:
			if opp.char_position in target_positions:
				selected_targets.append(opp)
				print("Selected opponent: ", opp.char_name)
	elif ability.target_type == "multiple_allies":
		for ally in current_character.ally_team:
			if ally.char_position in target_positions:
				selected_targets.append(ally)
				print("Selected ally: ", ally.char_name)
				
	print("Total targets auto-selected: ", selected_targets.size())

## Resetea los resaltados de todos los personajes en pantalla.
func _reset_all_highlights():
	print("Resetting all highlights")
	for character in battle_manager.participants:
		if character != null and character.has_method("highlight"):
			character.highlight(false)

## Cancela el modo de seleccion de objetivos, limpia variables relacionadas.
func _cancel_targeting():
	print("Canceling targeting mode")
	targeting_mode = false
	selected_ability = null
	selected_targets.clear()
	_reset_all_highlights()

## Manejador de evento cuando se hace clic en un personaje.
## [param character] Personaje clicado.
func _on_character_clicked(character):
	print("Character clicked: ", character.char_name)
	# Solo maneja clics si esta en modo de seleccion y hay habilidad activa
	if not targeting_mode or selected_ability == null:
		print("Not in targeting mode or no ability selected")
		return
		
	# Para habilidades multiple, ya se auto-seleccionaron objetivos
	if selected_ability.target_type.begins_with("multiple"):
		if _is_valid_target(character, selected_ability):
			print("Valid trigger for multi-target ability: ", character.char_name)
			_execute_current_ability(selected_targets)
		else:
			print("Clicked character not valid for triggering multi-target ability: ", character.char_name)
		return

	# Comprueba si el personaje es objetivo valido basado en tipo y posicion
	if _is_valid_target(character, selected_ability):
		print("Valid target selected: ", character.char_name)
		# Para habilidades single, selecciona y ejecuta inmediatamente
		selected_targets = [character]
		_execute_current_ability(selected_targets)
	else:
		print("Invalid target: ", character.char_name)

## Verifica si un personaje es objetivo valido para la habilidad seleccionada.
## [param character] Personaje a verificar.
## [param ability] Habilidad actual.
## [return] true si es valido, false en caso contrario.
func _is_valid_target(character, ability):
	print("Checking if ", character.char_name, " is valid target for ", ability.name)
	# Primero verifica si la posicion esta en el arreglo de posiciones validas
	if not character.char_position in ability.target_position:
		print("Position not valid: ", character.char_position, " not in ", ability.target_position)
		return false
		
	if ability.target_type in ["single_opp", "multiple_opps"] and character in current_character.opps_team:
		print("Valid opponent target")
		return true
	elif ability.target_type in ["single_ally", "multiple_allies"] and character in current_character.ally_team:
		print("Valid ally target")
		return true
	elif ability.target_type == "self" and character == current_character:
		print("Valid self target")
		return true
		
	print("Target type mismatch")
	return false

## Ejecuta la habilidad seleccionada con los objetivos dados.
## [param targets] Lista de personajes objetivo.
func _execute_current_ability(targets):
	if current_character and selected_ability:
		print("Executing ability: ", selected_ability.name, " with ", targets.size(), " targets")
		# Ejecuta la habilidad
		current_character.execute_ability(selected_ability, targets)
		
		# Sale de modo de seleccion de objetivos
		targeting_mode = false
		selected_ability = null
		selected_targets.clear()
		_reset_all_highlights()
		
		# Deshabilita botones despues del uso de habilidad
		print("Ability execution complete")
		current_character.emit_end_turn()
		
## Maneja eventos de entrada para cancelar modo de seleccion con clic derecho o Escape.
## [param event] Evento de entrada detectado.
func _input(event):
	if targeting_mode:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			print("Right click detected, canceling targeting")
			_cancel_targeting()
		elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
			print("Escape key detected, canceling targeting")
			_cancel_targeting()

## Manejador cuando se presiona el boton de opciones.
func _on_options_button_pressed() -> void:
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	options_menu.show_options_pop_up()

## Manejador cuando se presiona el boton de rendirse.
func _on_surrender_button_pressed() -> void:
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	surrender_menu.show_surrender_popup()

## Manejador de la señal de rendirse, emite fin de batalla con ganador enemigo.
func _on_giving_up() -> void:
	battle_bus.emit_signal("battle_end", "enemy")

## Manejador cuando se usa una habilidad masiva, provoca sacudida de pantalla.
func _on_massive_ability_used(_character,_ability,_targets):
	shake_screen()

## Intensidad de la sacudida de pantalla.
@export var shake_intensity: float = 5.0

## Offset original del canvas para restaurar posicion.
var original_offset: Vector2
## Tween usado para animar la sacudida.
var shake_tween: Tween

## Provoca una sacudida rapida del canvas con decaimiento exponencial.
func shake_screen():
	if shake_tween:
		shake_tween.kill()
	
	shake_tween = create_tween()
	
	# Sacudida rapida con decaimiento exponencial
	for i in range(8):
		var intensity = shake_intensity * pow(0.7, i)
		var random_pos = original_offset + Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		shake_tween.tween_property(canvas_layer, "offset", random_pos, 0.03)
	
	# Regresa al centro
	shake_tween.tween_property(canvas_layer, "offset", original_offset, 0.05)
