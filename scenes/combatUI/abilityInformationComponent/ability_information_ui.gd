extends Control
class_name AbilityInformationUI

@onready var ability_name = get_node("%AbilityNameLabel")
@onready var circles_container = get_node("%CirclesContainer")
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
var launch_borders
var target_circles
var target_borders

func _ready() -> void:
	populate_circle_arrays()

func populate_circle_arrays():
	launch_circles = []
	launch_borders = []
	for wrapper in launch_position_ui.get_children():
		var circle = wrapper.get_node("Circle")
		launch_circles.append(circle)
		var border = wrapper.get_node("MarginCircle")
		launch_borders.append(border)
	
	target_circles = []
	target_borders = []
	for wrapper in target_position_ui.get_children():
		var circle = wrapper.get_node("Circle")
		target_circles.append(circle)
		var border = wrapper.get_node("MarginCircle")
		target_borders.append(border)


func update_ability_information_ui(ability: AbilityData, is_enemy = false):

	if is_enemy:
		circles_container.scale.x = -1
		circles_container.position.x = circles_container.size.x 
	else:
		circles_container.scale.x = 1
		circles_container.position.x = 0

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
	reset_circles_to_default()

	var is_self = ability.target_type == "self"
	var is_support = ability.target_type in ["multiple_allies", "single_ally"]
	var target_color = get_target_color(ability.target_type)

	# Launch positions
	if ability.launch_position != null:
		for i in range(launch_circles.size()):
			var reverse_index = 3 - i #Index al reves para las posiciones
			var circle = launch_circles[i]
			var border = launch_borders[i]
			var position = reverse_index + 1  # Convierte el index a una posicion

			var is_launch_position = position in ability.launch_position
			var is_target_position = position in ability.target_position

			if is_self and is_launch_position:
				border.modulate = LAUNCH_POSITION_COLOR
			else:
				# Rule 1: Center coloring
				if is_launch_position:
					circle.modulate = LAUNCH_POSITION_COLOR
				else:
					circle.modulate = DEFAULT_COLOR

				# Rule 2: Border coloring
				if is_support and is_target_position:
					border.modulate = ALLY_TARGET_COLOR
				else:
					# Make it match the center (to look solid or default)
					border.modulate = circle.modulate

			

	# Target positions (only if not support or self)
	if not is_support and not is_self and ability.target_position != null:
		for i in range(target_circles.size()):
			var circle = target_circles[i]
			var border = target_borders[i]
			var position = i + 1  # 1-based

			if position in ability.target_position:
				circle.modulate = target_color
				border.modulate = target_color


func get_target_color(target_type: String) -> Color:
	match target_type:
		"multiple_opps", "single_opp":
			return ENEMY_TARGET_COLOR
		"multiple_allies", "single_ally", "self":
			return ALLY_TARGET_COLOR
		_:
			return DEFAULT_COLOR

func reset_circles_to_default():
	# Reset launch visuals
	if launch_circles and launch_borders:
		for i in launch_circles.size():
			var circle = launch_circles[i]
			var border = launch_borders[i]
			circle.modulate = DEFAULT_COLOR
			border.modulate = DEFAULT_COLOR

	# Reset target visuals
	if target_circles and target_borders:
		for i in target_circles.size():
			var circle = target_circles[i]
			var border = target_borders[i]
			circle.modulate = DEFAULT_COLOR
			border.modulate = DEFAULT_COLOR
