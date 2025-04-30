extends Control
class_name BattleUI

# UI States
enum UIState {
    IDLE,              # Waiting for battle events
    PLAYER_TURN,       # Player can select abilities
    ABILITY_TARGETING, # Player is selecting targets
    ENEMY_TURN,        # Showing enemy actions
    BATTLE_ENDED       # Victory/defeat screens
}

# Current UI state
var current_ui_state = UIState.IDLE
var event_bus: BattleEventBus

# Component references
@onready var turn_display = %TurnDisplayComponent
@onready var ability_panel = %AbilityPanelComponent
@onready var targeting_system = %TargetingSystemComponent
@onready var character_status_container = %CharacterStatusContainer
@onready var turn_order_display = %TurnOrderDisplayComponent
@onready var ability_information = %AbilityInformationComponent

func initialize(battle_manager, bus: BattleEventBus):
    event_bus = bus
    
    # Connect to key battle events
    event_bus.state_changed.connect(_on_battle_state_changed)
    event_bus.pre_turn.connect(_on_pre_turn)
    event_bus.ability_selected.connect(_on_ability_selected)
    event_bus.ability_targeting_cancelled.connect(_on_ability_targeting_cancelled)
    event_bus.ability_executed.connect(_on_ability_executed)
    event_bus.battle_end.connect(_on_battle_end)
    
    # Initialize components
    turn_display.initialize(event_bus)
    ability_panel.initialize(event_bus)
    targeting_system.initialize(event_bus)
    turn_order_display.initialize(battle_manager)
    character_status_container.initialize(event_bus, battle_manager.participants)
    
    # Start in IDLE state
    _change_ui_state(UIState.IDLE)

func _change_ui_state(new_state):
    var old_state = current_ui_state
    current_ui_state = new_state
    print("UI State changed: ", UIState.keys()[old_state], " -> ", UIState.keys()[new_state])
    
    # Exit current state
    match old_state:
        UIState.ABILITY_TARGETING:
            targeting_system.deactivate()
            
    # Enter new state
    match new_state:
        UIState.IDLE:
            ability_panel.deactivate()
        UIState.PLAYER_TURN:
            ability_panel.activate()
            turn_display.show_player_turn()
        UIState.ABILITY_TARGETING:
            targeting_system.activate()
        UIState.ENEMY_TURN:
            ability_panel.deactivate()
            turn_display.show_enemy_turn()
        UIState.BATTLE_ENDED:
            ability_panel.deactivate()
            targeting_system.deactivate()

# Event handlers
func _on_battle_state_changed(from_state, to_state):
    # Handle global battle state changes if needed
    pass
    
func _on_pre_turn(character):
    if character.alignment == BattleConstants.Alignment.PLAYER:
        _change_ui_state(UIState.PLAYER_TURN)
    else:
        _change_ui_state(UIState.ENEMY_TURN)

func _on_ability_selected(character, ability):
    if current_ui_state == UIState.PLAYER_TURN:
        ability_information.update_ability_information_ui(ability)
        _change_ui_state(UIState.ABILITY_TARGETING)

func _on_ability_targeting_cancelled(_character, _ability):
    if current_ui_state == UIState.ABILITY_TARGETING:
        _change_ui_state(UIState.PLAYER_TURN)

func _on_ability_executed(_character, _ability, _targets):
    # Return to IDLE after ability execution
    _change_ui_state(UIState.IDLE)

func _on_battle_end(_winner):
    _change_ui_state(UIState.BATTLE_ENDED)