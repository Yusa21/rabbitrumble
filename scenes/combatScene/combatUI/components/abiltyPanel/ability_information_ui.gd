extends Control
class_name AbilityInformationUI

@onready var ability_name = get_node("%AbilityNameLabel")
@onready var launch_position_ui = get_node("%LaunchPositionUI")
@onready var target_position_ui = get_node("%TargetPositionUI")
@onready var ability_mult_ui = get_node("%MultUI")
@onready var ability_description = get_node("%AbilityDescriptionLabel")

var battle_bus_event: BattleEventBus
var current_ability: AbilityData

func initialize(bus: BattleEventBus):
	battle_bus_event = bus
	battle_bus_event.ability_selected.connect(_on_ability_selected)

func update_ability_information_ui():
	# Add debug checks to find which node is null
	if ability_name == null:
		print("ability_name node is null!")
	else:
		ability_name.text = str(current_ability.name)
		
	if launch_position_ui == null:
		print("launch_position_ui node is null!")
	else:
		launch_position_ui.text = str(current_ability.get_launch_positions())
		
	if target_position_ui == null:
		print("target_position_ui node is null!")
	else:
		target_position_ui.text = str(current_ability.get_target_positions())
		
	if ability_mult_ui == null:
		print("ability_mult_ui node is null!")
	else:
		ability_mult_ui.text = str(current_ability.multiplier)
		
	if ability_description == null:
		print("ability_description node is null!")
	else:
		ability_description.text = current_ability.description
	
func _on_ability_selected(_character, ability: AbilityData):
	current_ability = ability

