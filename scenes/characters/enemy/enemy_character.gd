extends "res://scenes/characters/base_character.gd"
class_name EnemyCharacter
##Clase hija para los personajes enemigos, contiene la interaccion con la IA

##Se usa a la hora de identificar si un personaje es jugador o IA
const enemy_alignment = "enemy"

func _ready():
	set_alignment(enemy_alignment)

##Overrdide de la funcion de BaseCharacter para que active la IA
func start_turn():
	await execute_ai_ability()
	

##IA que ejecuta la habilidad del enemigo
func execute_ai_ability():
	var targeted_team ##Equipo al que apunta la habilidad aliado/oponente
	var targets ##Objetivos en especifico de la habilidad
	
	# Decide que equipo hay que selecionar
	if abilities[0].target_type.ends_with("ally") or abilities[0].target_type.ends_with("allies"):
		targeted_team = ally_team
	elif abilities[0].target_type.ends_with("opps") or abilities[0].target_type.ends_with("opp"):
		targeted_team = opps_team
	
	if targeted_team == null:
		push_error("Team is null when targeting in enemy AI")
		return
	
	#Si el multiple el equipo entero es el objetivo
	if abilities[0].target_type.begins_with("multiple"):
		targets = targeted_team
	elif abilities[0].target_type.begins_with("single"):
		var possible_positions = abilities[0].target_position
		
		# Filtra las posiciones que tienen personajes
		var occupied_positions = []
		for position in possible_positions:
			for character in targeted_team:
				if character.char_position == position:
					occupied_positions.append(position)
					break
		
		# Mira si hay al menos un objetivo disponible
		if occupied_positions.size() == 0:
			return
		
		# Si solo hay uno usalo directamente
		var selected_position
		if occupied_positions.size() == 1:
			selected_position = occupied_positions[0]
		else:
			# Si no, elige la posicion aleatoriamente
			var random_index = randi() % occupied_positions.size()
			selected_position = occupied_positions[random_index]
		
		# Encuentra el personaje en la posicion elegida 
		targets = []
		for character in targeted_team:
			if character.char_position == selected_position:
				targets.append(character)
				break
	
	execute_ability(abilities[0], targets)
