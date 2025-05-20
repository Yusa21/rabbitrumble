# FormationsManager.gd
extends Node2D
class_name FormationsManager

var screen_center: Vector2
var screen_size: Vector2

# Formation parameters
var character_spacing = 125
var team_offset_from_center = 0  # Distance from center to first character

func _ready():
	# Get screen dimensions
	screen_size = get_viewport().size
	screen_center = screen_size / 2

# Returns world position for a character based on team and position
func get_new_position(team_name: String, position_index: int) -> Vector2:
	var base_y = screen_center.y
	
	if team_name == "player":
		# Player team on left side
		var x = screen_center.x - team_offset_from_center - (position_index * character_spacing)
		var pos = Vector2(x, base_y)
		return pos
	else:
		# Enemy team on right side
		var x = screen_center.x + team_offset_from_center + (position_index * character_spacing)
		var pos = Vector2(x, base_y)
		return pos