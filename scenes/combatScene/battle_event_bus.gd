extends Resource
class_name BattleEventBus

# Battle state events
signal state_changed(from_state, to_state)
signal pre_turn(participant)
signal main_turn(participant)
signal post_turn(participant)
signal round_start(round_number)
signal round_end(round_number)
signal battle_start
signal battle_end(winner)

# Senales de personajes
signal stats_changed() # For HP/status updates
signal health_changed(character, current_health, max_health)
signal character_damaged(character, amount, source)
signal character_healed(character, amount, source)
signal status_effect_added(character, effect, source)
signal status_effect_removed(character, effect, source)
signal character_defeated(character)
signal character_moved(character)
signal ability_used(user ,ability, targets)
signal clicked(character)

# Senales de personaje del jugador

signal end_turn(player_character)

# Ability events
signal ability_selected(character, ability)
signal ability_targeting_started(character, ability)
signal ability_target_chosen(ability, targets)
signal ability_targeting_cancelled(character, ability)
signal ability_executed(character, ability, targets)
signal ability_effect_applied(target, effect, value)

# UI events
signal ui_element_clicked(element_name, element_data)
signal targeting_mode_changed(is_targeting)
signal turn_order_changed(turn_queue, active_char, unacted_chars)