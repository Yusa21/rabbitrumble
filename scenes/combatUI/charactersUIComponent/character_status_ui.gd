extends Control
## Interfaz de usuario que muestra el estado de un personaje durante la batalla.
## Se encarga de reflejar vida, nombre, efectos de estado y si es el turno del personaje.
class_name CharacterStatusUI

## Referencia a la barra de vida del personaje.
@onready var health_bar = get_node("%HealthBar")

## Etiqueta que muestra los valores numericos de la vida.
@onready var health_label = get_node("%HealthLabel")

## Etiqueta que muestra el nombre del personaje.
@onready var char_name_label = get_node("%NameLabel")

## Contenedor de efectos de estado visibles.
@onready var status_effects_container = get_node("%StatusEffect")

## Flecha indicadora que muestra si es el turno del personaje.
@onready var turn_indicator_arrow = get_node("%TurnIndicator")

## Referencia al personaje que refleja la interfaz
var character_ref: BaseCharacter = null

## Bus de eventos para manejar las actualizaciones del estado del personaje.
var battle_event_bus

## Inicializa la interfaz con el personaje y conecta eventos relevantes.
## [param character] Instancia del personaje que se va a mostrar.
## [param event_bus] Bus de eventos para conectarse a cambios del personaje.
func initialize(character: BaseCharacter, event_bus):
	character_ref = character
	battle_event_bus = event_bus
	char_name_label.text = character.char_name
	update_health_bar(character.current_hp, character.max_hp)
	## Se conecta al bus de eventos en lugar de directamente al personaje.
	battle_event_bus.health_changed.connect(_on_character_health_changed)
	battle_event_bus.character_moved.connect(_on_character_moved)
	battle_event_bus.pre_turn.connect(_on_character_pre_turn)
	update_position()

## Actualiza la barra de vida y la etiqueta con los valores actuales.
## [param current_health] Vida actual del personaje.
## [param max_health] Vida maxima del personaje.
func update_health_bar(current_health: int, max_health: int):
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_label.text = str(current_health) + "/" + str(max_health) # Add this line
	
	var health_percent = float(current_health) / max_health
	if health_percent < 0.25:
		health_bar.modulate = Color(1, 0, 0)
	elif health_percent < 0.5:
		health_bar.modulate = Color(1, 1, 0)
	else:
		health_bar.modulate = Color(0, 1, 0)

## Mueve la UI si el personaje se ha movido.
## [param moved_character] Personaje que ha sido movido.
func _on_character_moved(moved_character):
	if moved_character == character_ref:
		update_position()

## Actualiza la posicion de la interfaz para coincidir con la posicion del personaje.
func update_position():
	if character_ref and is_instance_valid(character_ref):
		var char_global_pos = character_ref.global_position
		global_position = char_global_pos

## Actualiza la vida cuando el personaje recibe dano o se cura.
## [param character] Personaje cuya vida ha cambiado.
## [param current_health] Nueva vida actual.
## [param max_health] Nueva vida maxima.
func _on_character_health_changed(character, current_health: int, max_health: int):
	if character == character_ref:
		update_health_bar(current_health, max_health)

## Muestra o esconde la flecha de turno segun si el personaje esta por actuar.
## [param turn_char] Personaje que esta por tomar su turno.
func _on_character_pre_turn(turn_char):
	if turn_char == character_ref:
		turn_indicator_arrow.visible = true
	else:
		turn_indicator_arrow.visible = false
