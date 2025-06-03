extends Control
## Componente de interfaz que gestiona el panel de habilidades en combate.
## Se encarga de mostrar y habilitar los botones de habilidad segun el personaje actual.
class_name AbilityPanelComponent

# Nodulos
@onready var ability_button_1 = get_node("%AbilityButton1")
@onready var ability_button_2 = get_node("%AbilityButton2")
@onready var ability_information_ui = get_node("%AbilityInformationUI")
@onready var pass_turn_button = get_node("%PassButton")

# Estado
var battle_bus
var current_character = null
var selected_ability = null
var selected_ability_index = -1

func _ready():
	## Conecta las senales de los botones
	ability_button_1.pressed.connect(_on_ability_button_1_pressed)
	ability_button_2.pressed.connect(_on_ability_button_2_pressed)
	pass_turn_button.pressed.connect(_on_pass_button_pressed)
	
	## Desactiva los botones inicialmente
	ability_button_1.disabled = false
	ability_button_2.disabled = false
	pass_turn_button.disabled = false

## Inicializa el componente con la referencia al bus de eventos de batalla.
## [param bus] Instancia del bus de eventos de batalla.
func initialize(bus: BattleEventBus):
	battle_bus = bus
	if ability_information_ui:
		pass
	else:
		push_error("Warning: Ability information UI not found in scene")

	## Conecta a las senales del bus de eventos
	battle_bus.pre_turn.connect(_on_pre_turn)
	battle_bus.main_turn.connect(_on_main_turn)
	battle_bus.post_turn.connect(_on_post_turn)
	battle_bus.battle_end.connect(_on_battle_end)
	battle_bus.ability_executed.connect(_on_ability_executed)
	
	print("AbilityPanelComponent initialized")

## Manejador del evento pre_turn. Se ejecuta antes del turno del personaje.
## [param character] Personaje que esta por tomar el turno.
func _on_pre_turn(character):
	## Reinicia el estado
	selected_ability = null
	selected_ability_index = -1
	
	## Actualiza la referencia del personaje actual
	current_character = character
	
	## Determina si es el turno de un personaje del jugador
	var is_player_turn = character.alignment == "player"
	
	## Habilita o deshabilita los botones segun sea necesario
	ability_button_1.disabled = !is_player_turn
	ability_button_2.disabled = !is_player_turn
	
	## Actualiza el contenido de los botones si es el turno del jugador
	if is_player_turn:
		_update_ability_buttons(character)

## Manejador del evento main_turn. No se necesita logica adicional aqui.
## [param character] Personaje que esta tomando el turno.
func _on_main_turn(_character):
	pass

## Manejador del evento post_turn. Se ejecuta al finalizar el turno del personaje.
## [param character] Personaje que acaba de finalizar su turno.
func _on_post_turn(_character):
	## Desactiva los botones al finalizar el turno
	ability_button_1.disabled = true
	ability_button_2.disabled = true
	
	## Reinicia la seleccion
	selected_ability = null
	selected_ability_index = -1

## Manejador del evento battle_end. Se ejecuta al finalizar la batalla.
## [param winner] Ganador de la batalla.
func _on_battle_end(_winner):
	## Desactiva los botones al terminar la batalla
	ability_button_1.disabled = true
	ability_button_2.disabled = true

## Actualiza los botones de habilidad con la informacion del personaje actual.
## [param character] Personaje del jugador actual.
func _update_ability_buttons(character):
	var abilities = character.abilities
	print("Updating ability buttons for: ", character.char_name, ", abilities count: ", abilities.size())
	
	## Actualiza el boton 1
	if abilities.size() > 0:
		ability_button_1.texture_normal = abilities[0].icon_sprite
		ability_button_1.texture_pressed = abilities[0].icon_pressed
		ability_button_1.texture_disabled = abilities[0].icon_disabled
		ability_button_1.tooltip_text = abilities[0].name
		## Verifica si la posicion del personaje permite usar esta habilidad
		if abilities[0].launch_position.has(character.char_position):
			ability_button_1.disabled = false
			print("Ability 1 enabled: ", abilities[0].name)
		else:
			ability_button_1.disabled = true
			print("Ability 1 disabled due to position:", abilities[0].name)
	else:
		ability_button_1.disabled = true
		print("No ability 1 available")
	
	# Actualiza el boton 2
	if abilities.size() > 1:
		ability_button_2.texture_normal = abilities[1].icon_sprite
		ability_button_2.texture_pressed = abilities[1].icon_pressed
		ability_button_2.texture_disabled = abilities[1].icon_disabled
		ability_button_2.tooltip_text = abilities[1].name

		# Verifica si la posicion del personaje permite usar esta habilidad
		if abilities[1].launch_position.has(character.char_position):
			ability_button_2.disabled = false
			print("Ability 2 enabled: ", abilities[1].name)
		else:
			ability_button_2.disabled = true
			print("Ability 2 disabled due to position:", abilities[1].name)
	else:
		ability_button_2.disabled = true
		print("No ability 2 available")

## Manejador para el boton de habilidad 1
func _on_ability_button_1_pressed():
	print("Ability button 1 pressed")
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	if current_character:
		_handle_ability_selection(0)

## Manejador para el boton de habilidad 2
func _on_ability_button_2_pressed():
	print("Ability button 2 pressed")
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	if current_character:
		_handle_ability_selection(1)

## Manejador para el boton de pasar turno
func _on_pass_button_pressed():
	print("Pass turn button pressed")
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	if current_character:
		_pass_turn()

## Maneja la seleccion de una habilidad
## [param ability_index] Indice de la habilidad seleccionada.
func _handle_ability_selection(ability_index):
	# Obtiene las habilidades del personaje actual
	var abilities = current_character.abilities
	if ability_index < abilities.size():
		selected_ability = abilities[ability_index]
		selected_ability_index = ability_index
		
		# Actualiza la interfaz de informacion de la habilidad
		if ability_information_ui:
			ability_information_ui.update_ability_information_ui(selected_ability)
			
		print("Selected ability: ", selected_ability.name)
		
		## Emite senal indicando que una habilidad fue seleccionada
		battle_bus.emit_signal("ability_selected", selected_ability, ability_index)
	else:
		print("No ability at index ", ability_index)

## Llama al metodo para finalizar el turno del personaje actual
func _pass_turn():
	current_character.emit_end_turn()

## Llamado por el sistema de seleccion de objetivos al completar la ejecucion de una habilidad
## [param ability] Habilidad que fue ejecutada.
## [param targets] Lista de objetivos.
func _on_ability_executed(_ability, targets):
	if current_character and selected_ability:
		print("Executing ability: ", selected_ability.name, " with ", targets.size(), " targets")
		
		# Desactiva los botones despues de usar una habilidad
		ability_button_1.disabled = true
		ability_button_2.disabled = true
		pass_turn_button.disabled = true
		
		# Reinicia la seleccion
		selected_ability = null
		selected_ability_index = -1
