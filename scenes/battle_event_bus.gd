extends Resource
class_name BattleEventBus

# Battle flow signals
signal battle_start
signal battle_end(winner)
signal round_start
signal round_end

# Turn management signals
signal pre_turn(participant)
signal main_turn(participant)
signal post_turn(participant)

# State management
signal state_changed(from_state, to_state)

# Character status signals
signal character_defeated(character)
signal health_changed(character, old_health, new_health)
signal ability_used(character, ability, targets)
signal character_stats_changed(character)
signal character_clicked(character)
signal character_moved(character)
signal character_position_changed(character)

# Status effect signals
signal status_effect_applied(character, effect)
signal status_effect_removed(character, effect_id)

# Character highlighting signals
signal character_highlight(character, enable)