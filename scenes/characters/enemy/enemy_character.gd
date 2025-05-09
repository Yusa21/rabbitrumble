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

	if abilities[0].target_type.ends_with("ally"):
		targeted_team = ally_team
	elif abilities[0].target_type.ends_with("opps") or abilities[0].target_type.ends_with("opp") :
		targeted_team = opps_team

	if targeted_team == null:
		push_error("Team is null when targeting in enemy AI")

	if abilities[0].target_type.begins_with("multiple"):
		targets = targeted_team
	elif abilities[0].target_type.begins_with("single"):
		var available_positions = abilities[0].target_position
		var random_index = randi() % available_positions.size()
		var random_position = available_positions[random_index]
	
   		# Find the character at that position in the targeted team
		targets = []
		for character in targeted_team:
			if character.char_position == random_position:
				targets.append(character)
				break

	execute_ability(abilities[0], targets)
