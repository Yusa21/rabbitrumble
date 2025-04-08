extends Node
class_name BattleStateMachine

# State definitions
enum BattleState {
	INIT,
	ROUND_START,
	PRE_TURN,
	MAIN_TURN,
	POST_TURN,
	ROUND_END,
	CHARACTER_DEFEATED,
	BATTLE_END
}

# Current state
var current_state: BattleState = BattleState.INIT

# Battle information
var battle_manager: TurnQueue  # Reference to your turn queue
var current_character = null   # Current character taking action
var defeat_queue = []          # Characters waiting to be processed for defeat
var player_team = []
var enemy_team = []
var participants = []

# Signals
signal state_changed(from_state, to_state)
signal battle_completed(winner)

func _init(manager: TurnQueue):
	battle_manager = manager

# Change state with appropriate transitions
func change_state(new_state: BattleState):
	var old_state = current_state
	current_state = new_state
	emit_signal("state_changed", old_state, new_state)
	
	# Process the new state
	match new_state:
		BattleState.INIT:
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
	# Initialize teams
	player_team = battle_manager.player_team.duplicate()
	enemy_team = battle_manager.enemy_team.duplicate()
	participants = player_team + enemy_team
	
	# Sort participants by speed
	participants.sort_custom(func(a, b): return a.speed > b.speed)
	
	# Connect defeat signals
	for character in participants:
		if !character.character_defeated.is_connected(_on_character_defeated):
			character.character_defeated.connect(_on_character_defeated)
	
	# Move to round start
	change_state(BattleState.ROUND_START)

func process_round_start():
	print("Round starting!")
	# Reset turn status
	for p in participants:
		p.has_taken_turn = false
	
	# Trigger round start abilities
	await battle_manager.process_phase_abilities("round_start")
	
	# Move to first character's pre-turn
	current_character = get_next_active_character()
	if current_character != null:
		change_state(BattleState.PRE_TURN)
	else:
		# No active characters - battle must be over
		change_state(BattleState.BATTLE_END)

func process_pre_turn():
	print("%s's turn (pre)" % current_character.char_name)
	battle_manager.active_character = current_character
	await battle_manager.process_phase_abilities("pre_turn")
	change_state(BattleState.MAIN_TURN)

func process_main_turn():
	print("%s's turn (main)" % current_character.char_name)
	await current_character.start_turn()
	current_character.has_taken_turn = true
	change_state(BattleState.POST_TURN)

func process_post_turn():
	print("%s's turn (post)" % current_character.char_name)
	await battle_manager.process_phase_abilities("post_turn")
	
	# Check for any pending defeats
	if defeat_queue.size() > 0:
		change_state(BattleState.CHARACTER_DEFEATED)
	else:
		# Find next character
		current_character = get_next_active_character()
		if current_character != null:
			change_state(BattleState.PRE_TURN)
		else:
			change_state(BattleState.ROUND_END)

func process_round_end():
	print("Round ending")
	await battle_manager.process_phase_abilities("round_end")
	
	# Check if battle should end
	if check_team_defeat():
		change_state(BattleState.BATTLE_END)
	else:
		change_state(BattleState.ROUND_START)

func process_character_defeated():
	while defeat_queue.size() > 0:
		var defeated = defeat_queue.pop_front()
		print("Processing defeat for %s" % defeated.char_name)
		
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
		current_character = get_next_active_character()
		if current_character != null:
			change_state(BattleState.PRE_TURN)
		else:
			change_state(BattleState.ROUND_END)

func process_battle_end():
	var winner = ""
	if player_team.size() > 0:
		winner = "player"
	else:
		winner = "enemy"
	
	print("Battle ended! Winner: %s" % winner)
	await battle_manager.process_phase_abilities("battle_end")
	emit_signal("battle_completed", winner)

# Helper functions
func get_next_active_character():
	# Find next character who hasn't taken a turn yet
	for p in participants:
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

# Signal handler for character defeat
func _on_character_defeated(character):
	print("%s signal defeated" % character.char_name)
	# Add to defeat queue to be processed at appropriate time
	if !defeat_queue.has(character):
		defeat_queue.append(character)
