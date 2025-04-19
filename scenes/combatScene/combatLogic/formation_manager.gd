# FormationsManager.gd
class_name FormationsManager
extends Resource

# Formation parameters
@export var character_spacing: float = 100
@export var team_offset_from_center: float = 0  # Distance from center to first character

# These will be set by the scene that owns this resource
var screen_center: Vector2
var screen_size: Vector2

# Returns world position for a character based on team and position
func get_new_position(team: BattleConstants.Alignment, position_index: int) -> Vector2:
	var base_y = screen_center.y
	
	if team == BattleConstants.Alignment.PLAYER:
		# Player team on left side
		var x = screen_center.x - team_offset_from_center - (position_index * character_spacing)
		return Vector2(x, base_y)
	else:
		# Enemy team on right side
		var x = screen_center.x + team_offset_from_center + (position_index * character_spacing)
		return Vector2(x, base_y)

# Initialize with screen information
func setup(viewport_size: Vector2):
	screen_size = viewport_size
	screen_center = screen_size / 2