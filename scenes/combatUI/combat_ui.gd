extends Control
class_name BattleUIController

# Reference to battle manager
var battle_manager: BattleManager
var current_character = null
var selected_ability = null
var selected_targets = []
var targeting_mode = false

var character_ui_scene = preload("res://scenes/combatUI/character_status_ui.tscn")
var character_ui_elements = {} 

@onready var state_label = get_node("%StateLabel")
@onready var ability_button_1 = get_node("%AbilityButton1")
@onready var ability_button_2 = get_node("%AbilityButton2")
@onready var turn_label = get_node("%TurnLabel")
@onready var character_ui_container = get_node("%CharacterUIContainer")
@onready var ability_information = get_node("%AbilityInformationUI")

func _ready():
	# Al principio desactiva los botones
	ability_button_1.disabled = true
	ability_button_2.disabled = true
	
	# Debug print
	print("BattleUIController ready")
	
	# Set up input handling for right click
	set_process_input(true)

func initialize(manager: BattleManager):
	battle_manager = manager
	print("BattleUIController initialized with battle manager: ", battle_manager)
	
	# Connect to battle manager signals
	battle_manager.state_changed.connect(_on_battle_state_changed)
	battle_manager.pre_turn.connect(_on_pre_turn)
	battle_manager.main_turn.connect(_on_main_turn)
	battle_manager.post_turn.connect(_on_post_turn)
	battle_manager.round_start.connect(_on_round_start)
	battle_manager.round_end.connect(_on_round_end)
	battle_manager.battle_start.connect(_on_battle_start)
	battle_manager.battle_end.connect(_on_battle_end)
	
	# Connect click events for all characters
	_connect_character_click_events()
	
	# Debug - print initial state
	print("Initial battle state: ", BattleManager.BattleState.keys()[battle_manager.current_state])
	
	# Set initial state label
	_update_state_label(battle_manager.current_state, battle_manager.current_state)
	
	# Force update to ensure UI reflects current state
	_force_update_ui_for_current_state()
	_create_character_ui_elements()

# Connect click handlers to all characters
func _connect_character_click_events():
	print("Connecting character click events. Participants count: ", battle_manager.participants.size())
	for character in battle_manager.participants:
		if character != null:
			if character.has_signal("clicked"):
				character.clicked.connect(_on_character_clicked)
				print("Connected click event for character: ", character.char_name)
			else:
				print("Warning: Character ", character.char_name, " doesn't have 'clicked' signal")

func _create_character_ui_elements():
	# Clear any existing UI elements first
	for ui in character_ui_elements.values():
		ui.queue_free()
	character_ui_elements.clear()
	
	# Create new UI elements for each character
	for character in battle_manager.participants:
		if character != null:
			var ui_instance = character_ui_scene.instantiate()
			character_ui_container.add_child(ui_instance)
			
			# Initialize the UI with character data
			ui_instance.initialize(character)
			
			# Store reference
			character_ui_elements[character] = ui_instance
			
			print("Created UI for character: ", character.char_name)

func _on_battle_state_changed(from_state, to_state):
	print("Battle state changed: ", BattleManager.BattleState.keys()[from_state], " -> ", BattleManager.BattleState.keys()[to_state])
	_update_state_label(from_state, to_state)
	
	# Reset highlighting when state changes (except from MAIN_TURN while targeting)
	if from_state != BattleManager.BattleState.MAIN_TURN or not targeting_mode:
		_reset_all_highlights()

func _update_state_label(from_state, to_state):
	var state_name = BattleManager.BattleState.keys()[to_state]
	state_label.text = "Battle Phase: " + state_name
	print("Updated state label to: ", state_label.text)

# Force update UI based on current battle state
func _force_update_ui_for_current_state():
	var current_state = battle_manager.current_state
	print("Forcing UI update for current state: ", BattleManager.BattleState.keys()[current_state])
	
	match current_state:
		BattleManager.BattleState.INIT:
			turn_label.text = "Battle Initializing..."
		BattleManager.BattleState.ROUND_START:
			turn_label.text = "Round Starting"
		BattleManager.BattleState.PRE_TURN, BattleManager.BattleState.MAIN_TURN, BattleManager.BattleState.POST_TURN:
			if battle_manager.active_character:
				current_character = battle_manager.active_character
				turn_label.text = current_character.char_name + "'s Turn"
				
				# Enable buttons for player character
				var is_player_turn = current_character.alignment == "player"
				ability_button_1.disabled = !is_player_turn
				ability_button_2.disabled = !is_player_turn
				
				if is_player_turn:
					_update_ability_buttons(current_character)
		BattleManager.BattleState.ROUND_END:
			turn_label.text = "Round Ending"
		BattleManager.BattleState.BATTLE_END:
			turn_label.text = "Battle Ended"

# Turn signals handlers
func _on_pre_turn(character):
	print("Pre-turn for character: ", character.char_name)
	current_character = character
	turn_label.text = character.char_name + "'s Turn"
	
	# Disable ability buttons during AI turns
	var is_player_turn = character.alignment == "player"
	ability_button_1.disabled = !is_player_turn
	ability_button_2.disabled = !is_player_turn
	
	# Update available abilities if it's a player character
	if is_player_turn:
		_update_ability_buttons(character)
	
	# Reset targeting
	_cancel_targeting()

func _on_main_turn(character):
	print("Main turn for character: ", character.char_name)
	# For AI characters, we wait for their turn to complete
	if (character.alignment != "player"):
		# AI character - no player input needed
		pass

func _on_post_turn(character):
	print("Post turn for character: ", character.char_name)
	# Clear current character reference after turn
	ability_button_1.disabled = true
	ability_button_2.disabled = true
	_reset_all_highlights()

func _on_round_start():
	print("Round starting")
	turn_label.text = "Round Starting"

func _on_round_end():
	print("Round ending")
	turn_label.text = "Round Ending"

func _on_battle_start():
	print("Battle starting")
	turn_label.text = "Battle Starting"

func _on_battle_end(winner):
	print("Battle ended. Winner: ", winner)
	turn_label.text = "Battle Ended - " + winner.capitalize() + " Wins!"
	ability_button_1.disabled = true
	ability_button_2.disabled = true
	_reset_all_highlights()

# Update ability buttons based on current character
func _update_ability_buttons(character):
	var abilities = character.abilities
	print("Updating ability buttons for: ", character.char_name, ", abilities count: ", abilities.size())
	
	# Update button 1
	if abilities.size() > 0:
		#Comprueba que el personaje este en una posicion donde se pueda usar la habilidad
		if abilities[0].launch_position.has(character.char_position):
			ability_button_1.disabled = false
			print("Ability 1 enabled: ", abilities[0].name)
		else:
			ability_button_1.disabled = true
			print("Ability 1 disabled due to position: ", abilities[0].name)
	else:
		ability_button_1.disabled = true
		ability_button_1.text = "No Ability"
		print("No ability 1 available")
	
	# Update button 2
	if abilities.size() > 1:
		#Comprueba que el personaje este en una posicion donde se pueda usar la habilidad
		if abilities[1].launch_position.has(character.char_position):
			ability_button_2.disabled = false
			print("Ability 2 enabled: ", abilities[1].name)
		else:
			ability_button_2.disabled = true
			print("Ability 2 disabled due to position: ", abilities[1].name)
	else:
		ability_button_2.disabled = true
		ability_button_2.text = "No Ability"
		print("No ability 2 available")
		
# Ability button handlers
func _on_ability_button_1_pressed():
	print("Ability button 1 pressed")
	if current_character and battle_manager.current_state == BattleManager.BattleState.MAIN_TURN:
		print("Handling ability 1 selection")
		_handle_ability_selection(0)
	else:
		print("Ability 1 press ignored. Current state: ", BattleManager.BattleState.keys()[battle_manager.current_state])

func _on_ability_button_2_pressed():
	print("Ability button 2 pressed")
	if current_character and battle_manager.current_state == BattleManager.BattleState.MAIN_TURN:
		print("Handling ability 2 selection")
		_handle_ability_selection(1)
	else:
		print("Ability 2 press ignored. Current state: ", BattleManager.BattleState.keys()[battle_manager.current_state])

func _handle_ability_selection(ability_index):
	# Reset any previous targeting
	_reset_all_highlights()
	selected_targets.clear()
	
	# Get the abilities of the current character
	var abilities = current_character.abilities
	if ability_index < abilities.size():
		selected_ability = abilities[ability_index]
		_update_ability_information(selected_ability)
		print("Selected ability: ", selected_ability.name)
		
		# Enter targeting mode
		targeting_mode = true
		
		turn_label.text = "Select target for " + selected_ability.name
		_highlight_possible_targets(selected_ability)
		
		# If this is a multi-target ability, automatically select all valid targets
		if selected_ability.target_type == "multiple_opps" or selected_ability.target_type == "multiple_allies":
			_auto_select_all_targets(selected_ability)
			print("Auto-selected targets for multi-target ability: ", selected_targets.size())
			# Execute immediately for multi-target abilities
			if selected_targets.size() > 0:
				_execute_current_ability(selected_targets)
			else:
				# No valid targets for multi-ability
				_cancel_targeting()
				turn_label.text = "No valid targets for " + selected_ability.name
	else:
		print("No ability at index ", ability_index)
		# Ability doesn't need targets, execute immediately
		_execute_current_ability([])

func _highlight_possible_targets(ability):
	print("Highlighting possible targets for ability: ", ability.name)
	var highlight_pos = ability.target_position
	var highlighted_count = 0
	
	if ability.target_type == "single_opp" || ability.target_type == "multiple_opps":
		for opp in current_character.opps_team:
			if opp.char_position in highlight_pos:
				opp.highlight(true)
				highlighted_count += 1
				print("Highlighted opponent: ", opp.char_name, " at position ", opp.char_position)
	elif ability.target_type == "single_ally" || ability.target_type == "multiple_allies":
		for ally in current_character.ally_team:
			if ally.char_position in highlight_pos:
				ally.highlight(true)
				highlighted_count += 1
				print("Highlighted ally: ", ally.char_name, " at position ", ally.char_position)
	elif ability.target_type == "self":
		current_character.highlight(true)
		highlighted_count += 1
		print("Highlighted self: ", current_character.char_name)
		
	print("Total targets highlighted: ", highlighted_count)

# Automatically select all valid targets for multi-target abilities
func _auto_select_all_targets(ability):
	selected_targets.clear()
	print("Auto-selecting targets for ", ability.name)
	
	var target_positions = ability.target_position
	
	if ability.target_type == "multiple_opps":
		for opp in current_character.opps_team:
			if opp.char_position in target_positions:
				selected_targets.append(opp)
				print("Selected opponent: ", opp.char_name)
	elif ability.target_type == "multiple_allies":
		for ally in current_character.ally_team:
			if ally.char_position in target_positions:
				selected_targets.append(ally)
				print("Selected ally: ", ally.char_name)
				
	print("Total targets auto-selected: ", selected_targets.size())

# Reset highlights for all characters
func _reset_all_highlights():
	print("Resetting all highlights")
	for character in battle_manager.participants:
		if character != null and character.has_method("highlight"):
			character.highlight(false)

# Cancel targeting mode
func _cancel_targeting():
	print("Canceling targeting mode")
	targeting_mode = false
	selected_ability = null
	selected_targets.clear()
	_reset_all_highlights()
	
	if current_character and current_character.alignment == "player":
		turn_label.text = current_character.char_name + "'s Turn"

# Handle character click events
func _on_character_clicked(character):
	print("Character clicked: ", character.char_name)
	# Only handle clicks when in targeting mode
	if not targeting_mode or selected_ability == null:
		print("Not in targeting mode or no ability selected")
		return
		
	# For multiple target abilities, we've already auto-selected all targets
	if selected_ability.target_type.begins_with("multiple"):
		print("Multiple target ability - ignoring click")
		return
		
	# Check if this character is valid target based on ability type and position
	if _is_valid_target(character, selected_ability):
		print("Valid target selected: ", character.char_name)
		# For single-target abilities, select and execute immediately
		selected_targets = [character]
		_execute_current_ability(selected_targets)
	else:
		print("Invalid target: ", character.char_name)

# Check if a character is a valid target for the selected ability
func _is_valid_target(character, ability):
	print("Checking if ", character.char_name, " is valid target for ", ability.name)
	# First check if character position is in target_position array
	if not character.char_position in ability.target_position:
		print("Position not valid: ", character.char_position, " not in ", ability.target_position)
		return false
		
	# Then check target type
	if ability.target_type.ends_with("opp") and character in current_character.opps_team:
		print("Valid opponent target")
		return true
	elif ability.target_type.ends_with("ally") and character in current_character.ally_team:
		print("Valid ally target")
		return true
	elif ability.target_type == "self" and character == current_character:
		print("Valid self target")
		return true
		
	print("Target type mismatch")
	return false

func _update_ability_information(selected_ability: AbilityData):
	ability_information.update_ability_information_ui(selected_ability)
	
# Execute the selected ability with targets
func _execute_current_ability(targets):
	if current_character and selected_ability:
		print("Executing ability: ", selected_ability.name, " with ", targets.size(), " targets")
		# Execute the ability
		current_character.execute_ability(selected_ability, targets)
		
		# Exit targeting mode
		targeting_mode = false
		selected_ability = null
		selected_targets.clear()
		_reset_all_highlights()
		
		# Update UI
		turn_label.text = current_character.char_name + "'s Turn"
		
		# Disable buttons after ability use
		ability_button_1.disabled = true
		ability_button_2.disabled = true
		print("Ability execution complete")
		current_character.emit_end_turn()

# Handle right-click for canceling targeting mode
func _input(event):
	if targeting_mode:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			print("Right click detected, canceling targeting")
			_cancel_targeting()
		elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
			print("Escape key detected, canceling targeting")
			_cancel_targeting()
