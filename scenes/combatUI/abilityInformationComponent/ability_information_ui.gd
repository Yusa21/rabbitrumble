extends Control
class_name AbilityInformationUI

@onready var ability_name = get_node("%AbilityNameLabel")
@onready var launch_position_ui = get_node("%LaunchPositonUI")
@onready var target_position_ui = get_node("%TargetPositionUI")
@onready var ability_mult_ui = get_node("%MultUI")
@onready var ability_targeting = get_node("%TargetingTypeUI")
@onready var ability_description = get_node("%AbilityDescriptionLabel")

const DEFAULT_COLOR = Color("#333333")
const ENEMY_TARGET_COLOR = Color("#cf291a")
const ALLY_TARGET_COLOR = Color("#2f9049")
const LAUNCH_POSITION_COLOR = Color("#f09e29")

var launch_circles
var target_circles

func _ready() -> void:
	populate_circle_arrays()

func populate_circle_arrays():
	launch_circles = launch_position_ui.get_children()
	target_circles = target_position_ui.get_children()

func update_ability_information_ui(ability: AbilityData):
	# Add debug checks to find which node is null
	if ability_name == null:
		print("ability_name node is null!")
	else:
		ability_name.text = str(ability.name)
	   
	if ability_mult_ui == null:
		print("ability_mult_ui node is null!")
	else:
		ability_mult_ui.text = "x" + str(ability.multiplier)

	if ability_targeting == null:
		print("ability_targeting node is null!")
	else:
		ability_targeting.text = get_ability_target_text(ability.target_type)
		
	if ability_description == null:
		print("ability_description node is null!")
	else:
		ability_description.text = ability.description
	
	# Update circles after setting the UI text
	update_ability_circles(ability)

func get_ability_target_text(target_type):
	match target_type:
		"multiple_opps":
			return "Multiple opponents"
		"single_opp":
			return "Single opponent"
		"multiple_allies":
			return "Multiple allies"
		"single_ally":
			return "Single ally"
		"self":
			return "Self"
		_:
			return " "


func update_ability_circles(ability: AbilityData):
	# Reset all circles to default color first
	reset_circles_to_default()
	
	# Color launch position circles
	if ability.launch_position != null:
		for position in ability.launch_position:
			if position >= 1 and position <= 4 and position <= launch_circles.size():
				var circle_index = position - 1  # Convert to 0-based index
				launch_circles[circle_index].modulate = LAUNCH_POSITION_COLOR
	
	# Color target position circles based on target type
	if ability.target_position != null:
		var target_color = get_target_color(ability.target_type)
		
		for position in ability.target_position:
			if position >= 1 and position <= 4 and position <= target_circles.size():
				var circle_index = position - 1  # Convert to 0-based index
				target_circles[circle_index].modulate = target_color

func get_target_color(target_type: String) -> Color:
	match target_type:
		"multiple_opps", "single_opp":
			return ENEMY_TARGET_COLOR
		"multiple_allies", "single_ally", "self":
			return ALLY_TARGET_COLOR
		_:
			return DEFAULT_COLOR

func reset_circles_to_default():
	# Reset launch circles
	if launch_circles != null:
		for circle in launch_circles:
			if circle != null:
				circle.modulate = DEFAULT_COLOR
	
	# Reset target circles
	if target_circles != null:
		for circle in target_circles:
			if circle != null:
				circle.modulate = DEFAULT_COLOR
