extends HBoxContainer
class_name TurnOrderDisplay

# Scene for individual turn indicators
var turn_indicator_scene = preload("res://scenes/combatUI/turn_indicator.tscn")
# Store the current turn indicators
var turn_indicators = []
# Maximum number of future turns to show
var max_future_turns = 4

# Reference to battle manager for turn order
var battle_manager: BattleManager

# Signal to notify when turn order is updated
signal turn_order_updated

func _ready():
	# Initialize container properties
	custom_minimum_size.y = 60
	alignment = BoxContainer.ALIGNMENT_BEGIN
	
func initialize(manager: BattleManager):
	battle_manager = manager
	# Connect to relevant signals
	battle_manager.round_start.connect(_on_round_start)
	battle_manager.pre_turn.connect(_on_pre_turn)
	battle_manager.post_turn.connect(_on_post_turn)
	battle_manager.battle_start.connect(_on_battle_start)
	battle_manager.battle_end.connect(_on_battle_end)
	
	# Initial setup of turn order
	update_turn_order()

# Update the visual turn order based on current participants
func update_turn_order():
	# Clear existing indicators
	clear_turn_indicators()
	
	# Get the current active character
	var active_character = battle_manager.active_character
	
	if active_character == null:
		# No active character yet, just show the initial order
		for i in range(min(battle_manager.participants.size(), max_future_turns + 1)):
			var character = battle_manager.participants[i]
			add_turn_indicator(character)
	else:
		# Find the index of the active character
		var active_index = battle_manager.participants.find(active_character)
		if active_index != -1:
			# Add the active character first
			add_turn_indicator(active_character)
			
			# Add upcoming turns
			var turns_added = 1
			for i in range(1, battle_manager.participants.size()):
				var next_index = (active_index + i) % battle_manager.participants.size()
				if turns_added <= max_future_turns:
					add_turn_indicator(battle_manager.participants[next_index])
					turns_added += 1
	
	# Emit signal that turn order has been updated
	emit_signal("turn_order_updated")

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

# Handle turn change
func _on_pre_turn(_character):
	update_turn_order()

# Handle round start - reset the display
func _on_round_start():
	update_turn_order()

# Handle turn end
func _on_post_turn(_character):
	update_turn_order()

# Handle battle start
func _on_battle_start():
	update_turn_order()

# Handle battle end
func _on_battle_end(_winner):
	clear_turn_indicators()

# Public method to update the display when the turn order changes
func handle_turn_order_changed():
	update_turn_order()
