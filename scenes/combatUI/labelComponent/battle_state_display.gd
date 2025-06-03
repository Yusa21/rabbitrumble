extends Control
## Componente de UI que muestra el estado actual de la batalla y el turno en curso.
## Escucha eventos del BattleEventBus para actualizar la interfaz en tiempo real.

# Elementos de la UI

## Etiqueta que muestra el estado actual de la batalla.
@onready var state_label = get_node("%StateLabel")
## Etiqueta que muestra el turno actual del personaje.
@onready var turn_label = get_node("%TurnLabel")

# Referencias

## Referencia al bus de eventos de batalla, utilizado para recibir actualizaciones de estado.
var battle_bus: BattleEventBus

# Constantes para los nombres de estado - se asume que coinciden con BattleManager.BattleState
## Diccionario que asocia los estados numericos con sus nombres legibles.
const STATE_NAMES = {
    0: "INIT",          ## Estado inicial de preparacion.
    1: "BATTLE_START",  ## Inicio de la batalla.
    2: "ROUND_START",   ## Inicio de la ronda.
    3: "PRE_TURN",      ## Antes del turno del personaje.
    4: "MAIN_TURN",     ## Turno principal del personaje.
    5: "POST_TURN",     ## Despues del turno del personaje.
    6: "ROUND_END",     ## Fin de la ronda.
    7: "BATTLE_END"     ## Fin de la batalla.
}

## Inicializa el componente y verifica que los nodos de UI esten presentes.
func _ready():
    # Asegura que los elementos de la UI esten inicializados
    if not state_label:
        push_error("StateLabel node not found in BattleStateDisplayComponent")
    if not turn_label:
        push_error("TurnLabel node not found in BattleStateDisplayComponent")

## Inicializa el componente con el bus de eventos y conecta las señales relevantes.
## [param bus] Instancia del BattleEventBus que emite los eventos de batalla.
func initialize(bus: BattleEventBus):
    battle_bus = bus

    # Conecta las señales del bus de eventos
    battle_bus.state_changed.connect(_on_battle_state_changed)
    battle_bus.pre_turn.connect(_on_pre_turn)
    battle_bus.main_turn.connect(_on_main_turn)
    battle_bus.post_turn.connect(_on_post_turn)
    battle_bus.round_start.connect(_on_round_start)
    battle_bus.round_end.connect(_on_round_end)
    battle_bus.battle_start.connect(_on_battle_start)
    battle_bus.battle_end.connect(_on_battle_end)

    print("BattleStateDisplayComponent initialized")

# Manejadores de eventos

## Maneja el cambio de estado de la batalla y actualiza la etiqueta correspondiente.
## [param from_state] Estado anterior.
## [param to_state] Nuevo estado.
func _on_battle_state_changed(from_state, to_state):
    print("Battle state changed: ", STATE_NAMES[from_state], " -> ", STATE_NAMES[to_state])
    _update_state_label(to_state)

## Actualiza el texto de la etiqueta de estado con el nombre del estado actual.
## [param state] Estado actual de la batalla (como numero entero).
func _update_state_label(state):
    var state_name = STATE_NAMES[state]
    state_label.text = "Battle Phase: " + state_name
    print("Updated state label to: ", state_label.text)

## Maneja el evento de pre-turno y muestra el nombre del personaje que va a actuar.
## [param character] Personaje cuyo turno va a comenzar.
func _on_pre_turn(character):
    turn_label.text = character.char_name + "'s Turn"
    print("Pre-turn for character: ", character.char_name)

## Maneja el evento de turno principal. Puede ser usado para actualizar la UI si es necesario.
## [param character] Personaje que esta tomando su turno.
func _on_main_turn(_character):
    # En caso de que necesitemos actualizar algo durante el turno principal
    pass

## Maneja el evento de post-turno, util para indicar el fin del turno.
## [param character] Personaje cuyo turno ha terminado.
func _on_post_turn(_character):
    pass

## Maneja el inicio de una nueva ronda.
func _on_round_start():
    turn_label.text = "Round Starting"

## Maneja el fin de una ronda.
func _on_round_end():
    turn_label.text = "Round Ending"

## Maneja el inicio de la batalla.
func _on_battle_start():
    turn_label.text = "Battle Starting"

## Maneja el fin de la batalla y muestra al ganador.
## [param winner] Nombre del equipo ganador.
func _on_battle_end(winner):
    turn_label.text = "Battle Ended - " + winner.capitalize() + " Wins!"
    print("Battle ended. Winner: ", winner)
