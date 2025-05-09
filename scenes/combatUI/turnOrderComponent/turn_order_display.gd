extends HBoxContainer
class_name TurnOrderDisplay

var turn_indicator_scene = preload("indicatorComponent/turn_indicator.tscn")
var turn_indicators = []
var max_future_turns = 4

var battle_manager: BattleManager
var battle_event_bus

func _ready():
	custom_minimum_size.y = 60
	alignment = BoxContainer.ALIGNMENT_BEGIN

func initialize(manager: BattleManager, event_bus):
	battle_manager = manager
	battle_event_bus = event_bus

	# Connect to event bus signals instead of manager directly
	battle_event_bus.round_start.connect(_on_round_start)
	battle_event_bus.pre_turn.connect(_on_pre_turn)
	battle_event_bus.post_turn.connect(_on_post_turn)
	battle_event_bus.battle_start.connect(_on_battle_start)
	battle_event_bus.battle_end.connect(_on_battle_end)

	update_turn_order()

func update_turn_order():
	clear_turn_indicators()

	var active_character = battle_manager.active_character

	if active_character == null:
		for i in range(min(battle_manager.participants.size(), max_future_turns + 1)):
			var character = battle_manager.participants[i]
			add_turn_indicator(character)
	else:
		var active_index = battle_manager.participants.find(active_character)
		if active_index != -1:
			add_turn_indicator(active_character)
			var turns_added = 1
			for i in range(1, battle_manager.participants.size()):
				var next_index = (active_index + i) % battle_manager.participants.size()
				if turns_added <= max_future_turns:
					add_turn_indicator(battle_manager.participants[next_index])
					turns_added += 1

func add_turn_indicator(character):
	var indicator = turn_indicator_scene.instantiate()
	add_child(indicator)
	indicator.initialize(character)
	turn_indicators.append(indicator)

func clear_turn_indicators():
	for indicator in turn_indicators:
		indicator.queue_free()
	turn_indicators.clear()

func _on_pre_turn(_character): update_turn_order()
func _on_round_start(): update_turn_order()
func _on_post_turn(_character): update_turn_order()
func _on_battle_start(): update_turn_order()
func _on_battle_end(_winner): clear_turn_indicators()