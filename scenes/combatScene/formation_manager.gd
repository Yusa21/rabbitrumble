# FormationsManager.gd
extends Node2D
class_name FormationsManager

var screen_center: Vector2
var screen_size: Vector2

# Formation parameters
var character_spacing = 100
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

# Draw helper function for debugging
func _draw():
	
		# Draw center marker
		draw_line(Vector2(screen_center.x - 1000, screen_center.y), 
				 Vector2(screen_center.x + 1000, screen_center.y), Color.YELLOW, 2)
		draw_line(Vector2(screen_center.x, screen_center.y - 1000), 
				 Vector2(screen_center.x, screen_center.y + 1000), Color.YELLOW, 2)
		
		# Draw formation positions for preview
		for i in range(4):
			# Player positions
			var player_pos = get_new_position("player", i)
			draw_circle(player_pos, 5, Color.BLUE)
			
			# Enemy positions
			var enemy_pos = get_new_position("enemy", i)
			draw_circle(enemy_pos, 5, Color.RED)
