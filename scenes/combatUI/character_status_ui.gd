extends Control
class_name CharacterStatusUI

@onready var health_bar = get_node("%HealthBar")
@onready var char_name_label = get_node("%NameLabel")
@onready var status_effects_container = get_node("%StatusEffect")

var character_ref: BaseCharacter = null

func initialize(character: BaseCharacter):
	character_ref = character
	char_name_label.text = character.char_name
	update_health_bar(character.current_hp, character.max_hp)
	
	# Connect to character signals
	character.health_changed.connect(_on_character_health_changed)
	character.status_effect_added.connect(_on_status_effect_added)
	character.status_effect_removed.connect(_on_status_effect_removed)
	character.character_moved.connect(_on_character_moved)
	# Position the UI initially
	update_position()

func _on_character_moved():
	update_position()

func update_position():
	# Get the character's position in global coordinates
	if character_ref and is_instance_valid(character_ref):
		var char_global_pos = character_ref.global_position
		# Convert to UI coordinates and add offset
		global_position = char_global_pos

func update_health_bar(current_health: int, max_health: int):
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	# Optional: Color the health bar based on percentage
	var health_percent = float(current_health) / max_health
	if health_percent < 0.25:
		health_bar.modulate = Color(1, 0, 0)  # Red when low
	elif health_percent < 0.5:
		health_bar.modulate = Color(1, 1, 0)  # Yellow when medium
	else:
		health_bar.modulate = Color(0, 1, 0)  # Green when high

# Signal handlers remain the same
func _on_character_health_changed(current_health: int, max_health: int):
	update_health_bar(current_health, max_health)

func _on_status_effect_added(effect):
	pass

func _on_status_effect_removed(effect_id):
	pass
