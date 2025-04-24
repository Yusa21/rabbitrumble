extends Control
class_name TurnDisplayComponent

var battle_event_bus: BattleEventBus
var current_character = null

@onready var turn_label = %TurnLabel
@onready var phase_label = %PhaseLabel

func initialize(bus: BattleEventBus):
    battle_event_bus = bus
    
    # Connect to relevant events
    battle_event_bus.pre_turn.connect(_on_pre_turn)
    battle_event_bus.state_changed.connect(_on_battle_state_changed)
    battle_event_bus.round_start.connect(_on_round_start)
    battle_event_bus.round_end.connect(_on_round_end)
    battle_event_bus.battle_start.connect(_on_battle_start)
    battle_event_bus.battle_end.connect(_on_battle_end)

func _on_pre_turn(character):
    current_character = character
    turn_label.text = character.char_name + "'s Turn"

func _on_battle_state_changed(_from_state, to_state):
    # Update phase label based on battle state
    var state_name = BattleConstants.BattleState.keys()[to_state]
    phase_label.text = "Battle Phase: " + state_name

func show_player_turn():
    if current_character:
        turn_label.text = current_character.char_name + "'s Turn - Select Ability"

func show_enemy_turn():
    if current_character:
        turn_label.text = current_character.char_name + " is acting..."

func show_targeting(ability_name):
    turn_label.text = "Select target for " + ability_name

func _on_round_start(round_number):
    turn_label.text = "Round " + str(round_number) + " Starting"

func _on_round_end(round_number):
    turn_label.text = "Round " + str(round_number) + " Ending"

func _on_battle_start():
    turn_label.text = "Battle Starting"

func _on_battle_end(winner):
    turn_label.text = "Battle Ended - " + winner.capitalize() + " Wins!"