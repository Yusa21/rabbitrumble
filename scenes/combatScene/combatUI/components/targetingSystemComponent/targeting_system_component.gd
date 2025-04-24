extends Node
class_name TargetingSystemComponent

var event_bus: BattleEventBus
var current_character = null
var selected_ability = null
var selected_targets = []

func initialize(bus: BattleEventBus):
    event_bus = bus
    
    # Connect to relevant events
    event_bus.ability_selected.connect(_on_ability_selected)
    event_bus.clicked.connect(_on_character_clicked)
    
    # Set up input handling
    set_process_input(true)

func activate():
    event_bus.targeting_mode_changed.emit(true)
    
    # Clear any previous selections
    selected_targets.clear()
    _reset_all_highlights()
    
    # Highlight possible targets
    if selected_ability and current_character:
        _highlight_possible_targets()
        
        # Auto-select targets for multi-target abilities
        if selected_ability.target_type == "multiple_opps" or selected_ability.target_type == "multiple_allies":
            _auto_select_all_targets()
            
            # Execute immediately for multi-target abilities
            if selected_targets.size() > 0:
                _execute_ability()
            else:
                _cancel_targeting()
        elif selected_ability.target_type == "self":
            # Auto-select self for self-targeting abilities
            selected_targets = [current_character]
            _execute_ability()

func deactivate():
    event_bus.targeting_mode_changed.emit(false)
    _reset_all_highlights()
    selected_targets.clear()

func _on_ability_selected(character, ability):
    current_character = character
    selected_ability = ability

func _on_character_clicked(character):
    if selected_ability and _is_valid_target(character, selected_ability):
        selected_targets = [character]
        _execute_ability()

func _highlight_possible_targets():
    var highlight_pos = selected_ability.target_position
    
    if selected_ability.target_type == "single_opp" || selected_ability.target_type == "multiple_opps":
        for opp in current_character.opps_team:
            if opp.char_position in highlight_pos:
                opp.highlight(true)
    elif selected_ability.target_type == "single_ally" || selected_ability.target_type == "multiple_allies":
        for ally in current_character.ally_team:
            if ally.char_position in highlight_pos:
                ally.highlight(true)
    elif selected_ability.target_type == "self":
        current_character.highlight(true)

func _auto_select_all_targets():
    selected_targets.clear()
    var target_positions = selected_ability.target_position
    
    if selected_ability.target_type == "multiple_opps":
        for opp in current_character.opps_team:
            if opp.char_position in target_positions:
                selected_targets.append(opp)
    elif selected_ability.target_type == "multiple_allies":
        for ally in current_character.ally_team:
            if ally.char_position in target_positions:
                selected_targets.append(ally)

func _is_valid_target(character, ability):
    # First check position
    if not character.char_position in ability.target_position:
        return false
        
    # Then check target type
    if ability.target_type.ends_with("opp") and character in current_character.opps_team:
        return true
    elif ability.target_type.ends_with("ally") and character in current_character.ally_team:
        return true
    elif ability.target_type == "self" and character == current_character:
        return true
        
    return false

func _reset_all_highlights():
    # This would need access to all battle participants
    # Could be refactored to use an event instead
    if current_character:
        for character in current_character.ally_team + current_character.opps_team:
            if character.has_method("highlight"):
                character.highlight(false)

func _execute_ability():
    event_bus.ability_executed.emit(current_character, selected_ability, selected_targets)
    current_character.execute_ability(selected_ability, selected_targets)
    current_character.emit_end_turn()
    deactivate()

func _cancel_targeting():
    event_bus.ability_targeting_cancelled.emit(current_character, selected_ability)
    deactivate()

func _input(event):
    if selected_ability:
        if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
            _cancel_targeting()
        elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
            _cancel_targeting()