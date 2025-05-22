extends Control
class_name AbilityInformationUI

@onready var ability_name = get_node("%AbilityNameLabel")
@onready var launch_position_ui = get_node("%LaunchPositionUI")
@onready var target_position_ui = get_node("%TargetPositionUI")
@onready var ability_mult_ui = get_node("%MultUI")
@onready var ability_targeting = get_node("%TargetingTypeUI")
@onready var ability_description = get_node("%AbilityDescriptionLabel")

func update_ability_information_ui(ability: AbilityData):
	# Add debug checks to find which node is null
	if ability_name == null:
		print("ability_name node is null!")
	else:
		ability_name.text = str(ability.name)
		
	if launch_position_ui == null:
		print("launch_position_ui node is null!")
	else:
		launch_position_ui.text = str(ability.launch_position)
		
	if target_position_ui == null:
		print("target_position_ui node is null!")
	else:
		target_position_ui.text = str(ability.target_position)
		
	if ability_mult_ui == null:
		print("ability_mult_ui node is null!")
	else:
		ability_mult_ui.text = str(ability.multiplier)

	if ability_targeting == null:
		print("ability_targeting_ui node is null!")
	else:
		ability_targeting.text = str(ability.target_type)
		
	if ability_description == null:
		print("ability_description node is null!")
	else:
		ability_description.text = ability.description
	
