extends "res://scenes/characters/base_character.gd"
class_name EnemyCharacter
##Clase hija para los personajes enemigos, contiene la interaccion con la IA
##
##Todavia esta casi vacia porque, en efecto, no hay IA

##Se usa a la hora de identificar si un personaje es jugador o IA
const enemy_alignment = "enemy"

func _ready():
	set_alignment(enemy_alignment)

func start_turn():
	print("Enemy turn started with id: " + str(id) + " in position " + str(char_position))
	print("With team " + str(ally_team))
	await execute_ai_ability()
	

func execute_ai_ability():
	var targeted_team
	var targets
	
	# Determine which team to target
	if abilities[0].target_type.ends_with("ally") or abilities[0].target_type.ends_with("allies"):
		targeted_team = ally_team
	elif abilities[0].target_type.ends_with("opps") or abilities[0].target_type.ends_with("opp"):
		targeted_team = opps_team
	
	if targeted_team == null:
		push_error("Team is null when targeting in enemy AI")
		return
	
	if abilities[0].target_type.begins_with("multiple"):
		targets = targeted_team
	elif abilities[0].target_type.begins_with("single"):
		# Get all possible target positions from the ability
		var possible_positions = abilities[0].target_position
		
		# Filter to only positions that actually have characters
		var occupied_positions = []
		for position in possible_positions:
			for character in targeted_team:
				if character.char_position == position:
					occupied_positions.append(position)
					break
		
		# Check if there are any valid targets
		if occupied_positions.size() == 0:
			print("Skipping turn")
			return
		
		# If only one valid target, use it directly
		var selected_position
		if occupied_positions.size() == 1:
			selected_position = occupied_positions[0]
		else:
			# Multiple valid targets, pick randomly
			var random_index = randi() % occupied_positions.size()
			selected_position = occupied_positions[random_index]
		
		# Find the character at the selected position
		targets = []
		for character in targeted_team:
			if character.char_position == selected_position:
				targets.append(character)
				break
	
	execute_ability(abilities[0], targets)
