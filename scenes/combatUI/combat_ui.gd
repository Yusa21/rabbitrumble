extends Control
class_name BattleUIController

# Reference to battle manager
var battle_manager: BattleManager
var current_character = null
var selected_ability = null
var selected_targets = []
var targeting_mode = false

var character_ui_scene = preload("charactersUIComponent/character_status_ui.tscn")
var character_ui_elements = {} 

var battle_bus: BattleEventBus

@onready var battle_state_display = get_node("%BattleStateDisplay")
@onready var character_ui_container = get_node("%CharacterUIContainer")
@onready var ability_panel = get_node("%AbilityPanel")
@onready var turn_order_display = get_node("%TurnOrderDisplay")

func _ready():
	# Debug print
	print("BattleUIController ready")
	
	# Set up input handling for right click
	set_process_input(true)

func initialize(manager: BattleManager, bus: BattleEventBus):
	battle_manager = manager
	battle_bus = bus
	print("BattleUIController initialized with battle manager: ", battle_manager)

	# Connect to event bus signals
	battle_bus.state_changed.connect(_on_battle_state_changed)
	battle_bus.pre_turn.connect(_on_pre_turn)
	battle_bus.main_turn.connect(_on_main_turn)
	battle_bus.post_turn.connect(_on_post_turn)
	battle_bus.battle_end.connect(_on_battle_end)
	battle_bus.character_clicked.connect(_on_character_clicked)
	battle_bus.ability_selected.connect(_handle_ability_selection)

	# Initialize turn order display with event bus
	if turn_order_display:
		turn_order_display.initialize(battle_manager, battle_bus)
	else:
		push_error("Warning: Turn order display not found in scene")
		
	if battle_state_display:
		battle_state_display.initialize(battle_bus)
	else:
		push_error("Warning: Battle state display not found in scene")

	if ability_panel:
		ability_panel.initialize(battle_bus)
	else:
		push_error("Warning: Ability panel not found in scene")


	print("Initial battle state: ", BattleManager.BattleState.keys()[battle_manager.current_state])
	_force_update_ui_for_current_state()
	_create_character_ui_elements()

	battle_bus.emit_signal("ui_initialized")

func _create_character_ui_elements():
	# Clear any existing UI elements first
	for ui in character_ui_elements.values():
		ui.queue_free()
	character_ui_elements.clear()

	for character in battle_manager.participants:
		if character != null:
			var ui_instance = character_ui_scene.instantiate()
			character_ui_container.add_child(ui_instance)
			ui_instance.initialize(character, battle_bus) # <- Pass bus
			character_ui_elements[character] = ui_instance
			print("Created UI for character: ", character.char_name)

func _on_battle_state_changed(from_state, to_state):
	print("Battle state changed: ", BattleManager.BattleState.keys()[from_state], " -> ", BattleManager.BattleState.keys()[to_state])
	
	# Reset highlighting when state changes (except from MAIN_TURN while targeting)
	if from_state != BattleManager.BattleState.MAIN_TURN or not targeting_mode:
		_reset_all_highlights()

# Force update UI based on current battle state
func _force_update_ui_for_current_state():
	var current_state = battle_manager.current_state
	print("Forcing UI update for current state: ", BattleManager.BattleState.keys()[current_state])
	
	match current_state:
		BattleManager.BattleState.INIT:
			pass
		BattleManager.BattleState.ROUND_START:
			pass
		BattleManager.BattleState.PRE_TURN, BattleManager.BattleState.MAIN_TURN, BattleManager.BattleState.POST_TURN:
			if battle_manager.active_character:
				current_character = battle_manager.active_character
				
				# Enable buttons for player character
				var is_player_turn = current_character.alignment == "player"

				
				if is_player_turn:
					_update_ability_buttons(current_character)

		BattleManager.BattleState.ROUND_END:
			pass
		BattleManager.BattleState.BATTLE_END:
			pass

# Turn signals handlers
func _on_pre_turn(character):
	print("Pre-turn for character: ", character.char_name)
	current_character = character
	
	# Disable ability buttons during AI turns
	var is_player_turn = character.alignment == "player"
	
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
	_reset_all_highlights()

func _on_battle_end(winner):
	print("Battle ended. Winner: ", winner)
	_reset_all_highlights()

# Update ability buttons based on current character
func _update_ability_buttons(character):
	var abilities = character.abilities
	print("Updating ability buttons for: ", character.char_name, ", abilities count: ", abilities.size())
	
	# Update button 1
	if abilities.size() > 0:
		#Comprueba que el personaje este en una posicion donde se pueda usar la habilidad
		if abilities[0].launch_position.has(character.char_position):
			print("Ability 1 enabled: ", abilities[0].name)
		else:
			print("Ability 1 disabled due to position: ", abilities[0].name)
	else:
		print("No ability 1 available")
	
	# Update button 2
	if abilities.size() > 1:
		#Comprueba que el personaje este en una posicion donde se pueda usar la habilidad
		if abilities[1].launch_position.has(character.char_position):
			print("Ability 2 enabled: ", abilities[1].name)
		else:
			print("Ability 2 disabled due to position: ", abilities[1].name)
	else:
		print("No ability 2 available")
		
func _handle_ability_selection(ability_data, ability_index):
	# Reset any previous targeting
	_reset_all_highlights()
	selected_targets.clear()
	
	# Get the abilities of the current character
	var abilities = current_character.abilities
	if ability_index < abilities.size():
		selected_ability = ability_data
		print("Selected ability: ", selected_ability.name)
		
		# Enter targeting mode
		targeting_mode = true
		
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
		
		# Disable buttons after ability use
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
