extends Node
class_name BattleManager

##Estado de combates
enum BattleState {
	BATTLE_START,
	ROUND_START,
	PRE_TURN,
	MAIN_TURN,
	POST_TURN,
	ROUND_END,
	CHARACTER_DEFEATED,
	BATTLE_END,
	
}

# Current state
var current_state: BattleState = BattleState.BATTLE_START

##Bus de eventos
var battle_event_bus: BattleEventBus

# Battle information
var player_team: Array
var enemy_team: Array
var participants: Array
var active_character = null
var defeat_queue: Array

# Initialize the battle with teams
func initialize(p_team: Array, e_team: Array, b_event_bus: BattleEventBus):
	player_team = p_team
	enemy_team = e_team
	battle_event_bus = b_event_bus
	participants = player_team + enemy_team
	
	# Setup team references for each character
	for player in player_team:
		player.ally_team = player_team
		player.opps_team = enemy_team
		battle_event_bus.character_defeated.connect(_on_character_defeated)
		player.update_position()
	
	for enemy in enemy_team:
		enemy.ally_team = enemy_team
		enemy.opps_team = player_team
		battle_event_bus.character_defeated.connect(_on_character_defeated)
		enemy.update_position()
	
	# Sort participants by speed
	_reorder_turn_queue()

	
	# Start the battle
	change_state(BattleState.BATTLE_START)

func _reorder_turn_queue():
	participants.sort_custom(func(a, b): return a.speed > b.speed)

	#Filtra los personajes que no han hecho turnos todavia
	var unacted_chars = participants.filter(func(character):
		return not character.has_taken_turn)
	
	battle_event_bus.emit_signal("turn_order_changed", participants, active_character, unacted_chars)

# Change state with appropriate transitions
func change_state(new_state: BattleState):
	var old_state = current_state
	current_state = new_state
	battle_event_bus.emit_signal("state_changed", old_state, new_state)
	
	# Emit the appropriate signals based on state
	match new_state:
		BattleState.BATTLE_START:
			battle_event_bus.emit_signal("battle_start")
		BattleState.ROUND_START:
			battle_event_bus.emit_signal("round_start")
		BattleState.PRE_TURN:
			battle_event_bus.emit_signal("pre_turn", active_character)
		BattleState.MAIN_TURN:
			battle_event_bus.emit_signal("main_turn", active_character)
		BattleState.POST_TURN:
			battle_event_bus.emit_signal("post_turn", active_character)
		BattleState.ROUND_END:
			battle_event_bus.emit_signal("round_end")
	
	# Process the new state
	match new_state:
		BattleState.BATTLE_START:
			await process_init_state()
		BattleState.ROUND_START:
			await process_round_start()
		BattleState.PRE_TURN:
			await process_pre_turn()
		BattleState.MAIN_TURN:
			await process_main_turn()
		BattleState.POST_TURN:
			await process_post_turn()
		BattleState.ROUND_END:
			await process_round_end()
		BattleState.CHARACTER_DEFEATED:
			await process_character_defeated()
		BattleState.BATTLE_END:
			await process_battle_end()

# State processing functions
func process_init_state():
	print("Battle starting!")
	change_state(BattleState.ROUND_START)

func process_round_start():
	print("Round starting!")
	# Reset turn status
	for p in participants:
		p.has_taken_turn = false
	
	# Trigger round start abilities
	await process_phase_abilities(BattleConstants.TriggerPhase.ROUND_START)
	
	# Move to first character's pre-turn
	active_character = get_next_active_character()
	if active_character != null:
		change_state(BattleState.PRE_TURN)
	else:
		# No active characters - battle must be over
		change_state(BattleState.BATTLE_END)

func process_pre_turn():
	# Fix: Use string formatting properly
	print(str(active_character.char_name) + "'s turn (pre)")
	await process_phase_abilities(BattleConstants.TriggerPhase.PRE_TURN)
	change_state(BattleState.MAIN_TURN)

func process_main_turn():
	# Fix: Use string formatting properly
	print(str(active_character.char_name) + "'s turn (main)")
	active_character.start_turn()
	active_character.has_taken_turn = true
	change_state(BattleState.POST_TURN)

func process_post_turn():
	# Fix: Use string formatting properly
	print(str(active_character.char_name) + "'s turn (post)")
	await process_phase_abilities(BattleConstants.TriggerPhase.POST_TURN)
	
	# Check for any pending defeats
	if defeat_queue.size() > 0:
		change_state(BattleState.CHARACTER_DEFEATED)
	else:
		# Find next character
		active_character = get_next_active_character()
		if active_character != null:
			change_state(BattleState.PRE_TURN)
		else:
			change_state(BattleState.ROUND_END)

func process_round_end():
	print("Round ending")
	await process_phase_abilities(BattleConstants.TriggerPhase.ROUND_END)
	
	# Check if battle should end
	if check_team_defeat():
		change_state(BattleState.BATTLE_END)
	else:
		change_state(BattleState.ROUND_START)

func process_character_defeated():
	while defeat_queue.size() > 0:
		var defeated = defeat_queue.pop_front()
		# Fix: Use string formatting properly
		print(str(defeated.char_name) + " has been defeated")
		
		# Remove from appropriate teams and participants list
		if defeated in player_team:
			player_team.erase(defeated)
		if defeated in enemy_team:
			enemy_team.erase(defeated)
		if defeated in participants:
			participants.erase(defeated)
	
	# Check if battle should end
	if check_team_defeat():
		change_state(BattleState.BATTLE_END)
	else:
		# Continue with turn sequence
		active_character = get_next_active_character()
		if active_character != null:
			change_state(BattleState.PRE_TURN)
		else:
			change_state(BattleState.ROUND_END)

func process_battle_end():
	var winner = ""
	if player_team.size() > 0:
		winner = "player"
	else:
		winner = "enemy"
	
	# Fix: Use string formatting properly
	print("Battle ended! Winner: " + winner)
	await process_phase_abilities(BattleConstants.TriggerPhase.BATTLE_END)
	emit_signal("battle_end", winner)

# Process phase abilities
func process_phase_abilities(phase_trigger: BattleConstants.TriggerPhase):
	# For global triggers (round/battle related), active_character is irrelevant
	var is_global_trigger = BattleConstants.GLOBAL_TRIGGERS.has(phase_trigger)
	
	# Process triggers for all characters
	for character in participants:
		# Check for null objects
		if character == null:
			push_error("Warning: Found null character in participants array")
			continue
			
		# Fix: Add safety check for method existence
		if not character.has_method("get_phase_triggered_abilities"):
			push_error("Warning: Character " + str(character) + " doesn't have get_phase_triggered_abilities method")
			continue
			
		var triggered_abilities = character.get_phase_triggered_abilities(phase_trigger)
		
		for ability in triggered_abilities:
			# Fix: Add null check for ability
			if ability == null:
				print("Warning: Null ability found for character " + str(character.char_name))
				continue
				
			if character.can_use_ability(ability):
				# Check if ability should trigger based on whose turn it is
				if is_global_trigger || should_ability_trigger(ability, character, active_character):
					var targets = character.automatic_targeting(ability)
					if targets.size() > 0:
						await character.execute_ability(ability, targets)

# Helper functions
func get_next_active_character():
	# Find next character who hasn't taken a turn yet
	for p in participants:
		# Fix: Add null check
		if p == null:
			continue
			
		if !p.has_taken_turn and !p.is_defeated:
			return p
	return null

func check_team_defeat():
	# Check if player team is defeated
	if player_team.size() == 0:
		return true
	
	# Check if enemy team is defeated
	if enemy_team.size() == 0:
		return true
	
	return false

# Should ability trigger based on character relationships
func should_ability_trigger(ability, character, active_char):
	# Fix: Add null check for active_char
	if active_char == null:
		return false
		
	# If it's the character's own turn
	if character == active_char && ability.trigger_on_self_turn:
		return true
		
	# If it's an ally's turn
	if character != active_char && is_ally(character, active_char) && ability.trigger_on_ally_turn:
		return true
		
	# If it's an enemy's turn
	if character != active_char && !is_ally(character, active_char) && ability.trigger_on_enemy_turn:
		return true
		
	# If none of the turn trigger conditions are specified, don't trigger by default for turn triggers
	return false

# Helper function to check if two characters are allies
func is_ally(character1, character2):
	# Fix: Add null checks
	if character1 == null or character2 == null:
		return false
	if not character1.has_method("ally_team") or not character2.has_method("ally_team"):
		return false
		
	return character1.ally_team.has(character2) && character2.ally_team.has(character1)

# Signal handler for character defeat
func _on_character_defeated(character):
	# Fix: Use string formatting properly
	print(str(character.char_name) + " signal defeated")
	# Add to defeat queue to be processed at appropriate time
	if !defeat_queue.has(character):
		defeat_queue.append(character)
