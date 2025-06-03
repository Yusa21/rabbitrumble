extends HBoxContainer
## Componente de interfaz que muestra el orden de turnos de los personajes en combate.
class_name TurnOrderDisplay

## Escena del indicador de turno precargada.
var turn_indicator_scene = preload("indicatorComponent/turn_indicator.tscn")

## Lista de indicadores de turno actualmente mostrados.
var turn_indicators = []

## Cantidad maxima de turnos futuros que se mostraran.
var max_future_turns = 4

## Referencia al gestor de combate.
var battle_manager: BattleManager

## Referencia al bus de eventos del combate.
var battle_event_bus

## Inicializa el componente y ajusta configuraciones visuales.
func _ready():
	custom_minimum_size.y = 60
	alignment = BoxContainer.ALIGNMENT_BEGIN

## Configura el componente con referencias al gestor de combate y bus de eventos.
## [param manager] Instancia de BattleManager.
## [param event_bus] Bus de eventos que emite las senales del combate.
func initialize(manager: BattleManager, event_bus):
	battle_manager = manager
	battle_event_bus = event_bus

	# Conectar a las senales del bus de eventos en lugar del gestor directamente
	battle_event_bus.round_start.connect(_on_round_start)
	battle_event_bus.pre_turn.connect(_on_pre_turn)
	battle_event_bus.post_turn.connect(_on_post_turn)
	battle_event_bus.battle_start.connect(_on_battle_start)
	battle_event_bus.battle_end.connect(_on_battle_end)

	update_turn_order()

## Actualiza la lista de indicadores de turno segun el estado actual del combate.
func update_turn_order():
	clear_turn_indicators()

	var active_character = battle_manager.active_character

	if active_character == null:
		for i in range(min(battle_manager.participants.size(), max_future_turns + 1)):
			var character = battle_manager.participants[i]
			add_turn_indicator(character)
	else:
		var active_index = battle_manager.participants.find(active_character)
		if active_index != -1:
			add_turn_indicator(active_character)
			var turns_added = 1
			for i in range(1, battle_manager.participants.size()):
				var next_index = (active_index + i) % battle_manager.participants.size()
				if turns_added <= max_future_turns:
					add_turn_indicator(battle_manager.participants[next_index])
					turns_added += 1

## Crea y agrega un nuevo indicador visual para el personaje dado.
## [param character] Personaje del que se mostrara el turno.
func add_turn_indicator(character):
	var indicator = turn_indicator_scene.instantiate()
	add_child(indicator)
	indicator.initialize(character)
	turn_indicators.append(indicator)

## Elimina todos los indicadores de turno actuales.
func clear_turn_indicators():
	for indicator in turn_indicators:
		indicator.queue_free()
	turn_indicators.clear()

## Manejadores de senales del combate que actualizan o limpian los indicadores.
func _on_pre_turn(_character): update_turn_order()
func _on_round_start(): update_turn_order()
func _on_post_turn(_character): update_turn_order()
func _on_battle_start(): update_turn_order()
func _on_battle_end(_winner): clear_turn_indicators()
