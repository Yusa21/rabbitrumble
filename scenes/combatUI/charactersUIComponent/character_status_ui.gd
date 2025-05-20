extends Control
class_name CharacterStatusUI

@onready var health_bar = get_node("%HealthBar")
@onready var char_name_label = get_node("%NameLabel")
@onready var status_effects_container = get_node("%StatusEffect")
@onready var turn_indicator_arrow = get_node("%TurnIndicator")

var character_ref: BaseCharacter = null
var battle_event_bus

func initialize(character: BaseCharacter, event_bus):
	character_ref = character
	battle_event_bus = event_bus

	char_name_label.text = character.char_name
	update_health_bar(character.current_hp, character.max_hp)

	# Connect to event bus instead of directly to character
	battle_event_bus.health_changed.connect(_on_character_health_changed)
	battle_event_bus.status_effect_applied.connect(_on_status_effect_added)
	battle_event_bus.status_effect_removed.connect(_on_status_effect_removed)
	battle_event_bus.character_moved.connect(_on_character_moved)
	battle_event_bus.pre_turn.connect(_on_character_pre_turn)

	update_position()

func _on_character_moved(moved_character):
	if moved_character == character_ref:
		update_position()

func update_position():
	if character_ref and is_instance_valid(character_ref):
		var char_global_pos = character_ref.global_position
		global_position = char_global_pos

func update_health_bar(current_health: int, max_health: int):
	health_bar.max_value = max_health
	health_bar.value = current_health

	var health_percent = float(current_health) / max_health
	if health_percent < 0.25:
		health_bar.modulate = Color(1, 0, 0)
	elif health_percent < 0.5:
		health_bar.modulate = Color(1, 1, 0)
	else:
		health_bar.modulate = Color(0, 1, 0)

func _on_character_health_changed(character, current_health: int, max_health: int):
	if character == character_ref:
		update_health_bar(current_health, max_health)

func _on_character_pre_turn(turn_char):
	if turn_char == character_ref:
		turn_indicator_arrow.visible = true
	else:
		turn_indicator_arrow.visible = false

func _on_status_effect_added(character, effect):
	if character == character_ref:
		# Add visual indicator or update UI here
		pass

func _on_status_effect_removed(character, effect_id):
	if character == character_ref:
		# Remove visual indicator or update UI here
		pass
