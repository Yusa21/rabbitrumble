extends Control
class_name AbilityPanelComponent

# Nodes
@onready var ability_button_1 = get_node("%AbilityButton1")
@onready var ability_button_2 = get_node("%AbilityButton2")
@onready var ability_information_ui = get_node("%AbilityInformationUI")
@onready var pass_turn_button = get_node("%PassButton")

# State
var battle_bus
var current_character = null
var selected_ability = null
var selected_ability_index = -1

func _ready():
	# Connect button signals
	ability_button_1.pressed.connect(_on_ability_button_1_pressed)
	ability_button_2.pressed.connect(_on_ability_button_2_pressed)
	pass_turn_button.pressed.connect(_on_pass_button_pressed)
	
	# Initially disable buttons
	ability_button_1.disabled = false
	ability_button_2.disabled = false
	pass_turn_button.disabled = false

func initialize(bus: BattleEventBus):
	battle_bus = bus
	if ability_information_ui:
		pass
	else:
		push_error("Warning: Ability information UI not found in scene")

	# Connect to event bus signals
	battle_bus.pre_turn.connect(_on_pre_turn)
	battle_bus.main_turn.connect(_on_main_turn)
	battle_bus.post_turn.connect(_on_post_turn)
	battle_bus.battle_end.connect(_on_battle_end)
	battle_bus.ability_executed.connect(_on_ability_executed)
	
	print("AbilityPanelComponent initialized")

func _on_pre_turn(character):
	# Reset state
	selected_ability = null
	selected_ability_index = -1
	
	# Update current character reference
	current_character = character
	
	# Determine if it's a player character's turn
	var is_player_turn = character.alignment == "player"
	
	# Update ability buttons accordingly
	ability_button_1.disabled = !is_player_turn
	ability_button_2.disabled = !is_player_turn
	
	# Update button content if it's a player's turn
	if is_player_turn:
		_update_ability_buttons(character)

func _on_main_turn(character):
	# No special handling needed here, pre_turn already set up the buttons
	pass

func _on_post_turn(character):
	# Disable ability buttons after turn
	ability_button_1.disabled = true
	ability_button_2.disabled = true
	
	# Reset selection
	selected_ability = null
	selected_ability_index = -1

func _on_battle_end(winner):
	# Disable buttons when battle ends
	ability_button_1.disabled = true
	ability_button_2.disabled = true

func _update_ability_buttons(character):
	var abilities = character.abilities
	print("Updating ability buttons for: ", character.char_name, ", abilities count: ", abilities.size())
	
	# Update button 1
	if abilities.size() > 0:
		ability_button_1.texture_normal = abilities[0].icon_sprite
		ability_button_1.texture_pressed = abilities[0].icon_pressed
		ability_button_1.texture_disabled = abilities[0].icon_disabled
		# Check if character position allows using this ability
		if abilities[0].launch_position.has(character.char_position):
			ability_button_1.disabled = false
			
			print("Ability 1 enabled: ", abilities[0].name)
		else:
			ability_button_1.disabled = true
			
			print("Ability 1 disabled due to position:", abilities[0].name)
	else:
		ability_button_1.disabled = true
		print("No ability 1 available")
	
	# Update button 2
	if abilities.size() > 1:
		ability_button_2.texture_normal = abilities[0].icon_sprite
		ability_button_2.texture_pressed = abilities[0].icon_pressed
		ability_button_2.texture_disabled = abilities[0].icon_disabled
		
		# Check if character position allows using this ability
		if abilities[1].launch_position.has(character.char_position):
			ability_button_2.disabled = false
			print("Ability 2 enabled: ", abilities[1].name)
		else:
			ability_button_2.disabled = true
			print("Ability 2 disabled due to position:", abilities[1].name)
	else:
		ability_button_2.disabled = true
		print("No ability 2 available")

func _on_ability_button_1_pressed():
	print("Ability button 1 pressed")
	if current_character:
		_handle_ability_selection(0)

func _on_ability_button_2_pressed():
	print("Ability button 2 pressed")
	if current_character:
		_handle_ability_selection(1)

func _on_pass_button_pressed():
	print("Pass turn button pressed")
	if current_character:
		_pass_turn()

func _handle_ability_selection(ability_index):
	# Get the abilities of the current character
	var abilities = current_character.abilities
	if ability_index < abilities.size():
		selected_ability = abilities[ability_index]
		selected_ability_index = ability_index
		
		# Update ability information display
		if ability_information_ui:
			ability_information_ui.update_ability_information_ui(selected_ability)
			
		print("Selected ability: ", selected_ability.name)
		
		# Emit signal that ability was selected
		battle_bus.emit_signal("ability_selected", selected_ability, ability_index)
	else:
		print("No ability at index ", ability_index)

func _pass_turn():
	current_character.emit_end_turn()


# Called by the targeting system when targeting is complete to reset the buttons
func _on_ability_executed(ability, targets):
	if current_character and selected_ability:
		print("Executing ability: ", selected_ability.name, " with ", targets.size(), " targets")
		
		# Disable buttons after ability use
		ability_button_1.disabled = true
		ability_button_2.disabled = true
		pass_turn_button.disabled = true
		
		# Reset selection
		selected_ability = null
		selected_ability_index = -1
