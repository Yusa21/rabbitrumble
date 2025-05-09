extends Control
# UI elements

@onready var state_label = get_node("%StateLabel")
@onready var turn_label = get_node("%TurnLabel")

# References
var battle_bus: BattleEventBus

# Constants for state names - assuming they match BattleManager.BattleState
const STATE_NAMES = {
    0: "INIT",
    1: "BATTLE_START",
    2: "ROUND_START",
    3: "PRE_TURN",
    4: "MAIN_TURN",
    5: "POST_TURN",
    6: "ROUND_END",
    7: "BATTLE_END"
}

func _ready():
    # Ensure UI elements are initialized
    if not state_label:
        push_error("StateLabel node not found in BattleStateDisplayComponent")
    if not turn_label:
        push_error("TurnLabel node not found in BattleStateDisplayComponent")

func initialize(bus: BattleEventBus):
    battle_bus = bus
    
    # Connect to event bus signals
    battle_bus.state_changed.connect(_on_battle_state_changed)
    battle_bus.pre_turn.connect(_on_pre_turn)
    battle_bus.main_turn.connect(_on_main_turn)
    battle_bus.post_turn.connect(_on_post_turn)
    battle_bus.round_start.connect(_on_round_start)
    battle_bus.round_end.connect(_on_round_end)
    battle_bus.battle_start.connect(_on_battle_start)
    battle_bus.battle_end.connect(_on_battle_end)
    
    print("BattleStateDisplayComponent initialized")

# Event handlers
func _on_battle_state_changed(from_state, to_state):
    print("Battle state changed: ", STATE_NAMES[from_state], " -> ", STATE_NAMES[to_state])
    _update_state_label(to_state)

func _update_state_label(state):
    var state_name = STATE_NAMES[state]
    state_label.text = "Battle Phase: " + state_name
    print("Updated state label to: ", state_label.text)

func _on_pre_turn(character):
    turn_label.text = character.char_name + "'s Turn"
    print("Pre-turn for character: ", character.char_name)

func _on_main_turn(character):
    # In case we need to update anything during main turn
    pass

func _on_post_turn(character):
    # You might want to update turn label to indicate turn is ending
    print("Post turn for character: ", character.char_name)

func _on_round_start():
    turn_label.text = "Round Starting"
    print("Round starting")

func _on_round_end():
    turn_label.text = "Round Ending"
    print("Round ending")

func _on_battle_start():
    turn_label.text = "Battle Starting"
    print("Battle starting")

func _on_battle_end(winner):
    turn_label.text = "Battle Ended - " + winner.capitalize() + " Wins!"
    print("Battle ended. Winner: ", winner)