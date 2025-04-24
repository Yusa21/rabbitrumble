extends HBoxContainer
class_name TurnOrderDisplay

# Scene for individual turn indicators
var turn_indicator_scene = preload("./indicator/turn_indicator.tscn")
# Store the current turn indicators
var turn_indicators = []
# Maximum number of future turns to show
var max_future_turns = 7

# Reference to battle manager for turn order
var battle_event_bus: BattleEventBus
var battle_characters: Array
var active_char: Array
var unacted_chars: Array

func _ready():
	# Initialize container properties
	custom_minimum_size.y = 60
	alignment = BoxContainer.ALIGNMENT_BEGIN
	
func initialize(characters: Array, bus: BattleEventBus):
	battle_characters = characters
	battle_event_bus = bus
	# Connect to relevant signals
	battle_event_bus.pre_turn.connect(_on_next_turn)
	battle_event_bus.turn_order_changed.connect(_on_turn_order_changed)
	
	# Initial setup of turn order
	setup_initial_turn_order()

func setup_initial_turn_order():
	for i in range(min(battle_characters.size(), max_future_turns + 1)):
			var character = battle_characters[i]
			add_turn_indicator(character)

# Add a turn indicator for a character
func add_turn_indicator(character):
	var indicator = turn_indicator_scene.instantiate()
	add_child(indicator)
	indicator.initialize(character)
	turn_indicators.append(indicator)

# Clear all turn indicators
func clear_turn_indicators():
	for indicator in turn_indicators:
		indicator.queue_free()
	turn_indicators.clear()

# When advancing to the next turn
func _on_next_turn(active_character):
	# Remove the first indicator (previous active character)
	if turn_indicators.size() > 0:
		turn_indicators[0].queue_free()
		turn_indicators.remove_at(0)
    
    # If we need to add a new character at the end of our display
	if turn_indicators.size() < max_future_turns:
		var active_index = battle_characters.find(active_character)
		if active_index != -1:
			var next_char_index = (active_index + turn_indicators.size() + 1) % battle_characters.size()
			add_turn_indicator(battle_characters[next_char_index])

# When the turn order changes
func _on_turn_order_changed(turn_queue: Array, active_character, unacted_characters: Array):
    # Store the updated battle characters array
	battle_characters = turn_queue
	self.active_char = active_character
	self.unacted_chars = unacted_characters
    
    # Clear current indicators
	clear_turn_indicators()
    
    # First add the active character
	add_turn_indicator(active_character)
    
    # Next add all unacted characters (they get priority in the display)
	var turns_added = 1
	for character in unacted_chars:
		if character != active_character and turns_added <= max_future_turns:
			add_turn_indicator(character)
			turns_added += 1
    
    # Then add characters from the normal turn queue until we reach max_future_turns
	if turns_added <= max_future_turns:
		var active_index = battle_characters.find(active_character)
		if active_index != -1:
			for i in range(1, battle_characters.size()):
				var next_index = (active_index + i) % battle_characters.size()
				var next_char = battle_characters[next_index]
                
				# Only add if not already added as an unacted character
				if not unacted_chars.has(next_char) and turns_added <= max_future_turns:
					add_turn_indicator(next_char)
					turns_added += 1