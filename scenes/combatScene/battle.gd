extends Node
class_name Battle
##Clase que incializa el combate
##
##Recibe los personajes que tiene que estar involucrados en el combate y incializa el combate
##instanciando las escenas de los personajes necesarios y aportando los datos necesarios 
@onready var battle_manager

##Constantes para evitar datos sin explicar en mitad del codigo
const player_char_path = "res://scenes/characters/player/player_character.tscn"
const enemy_char_path = "res://scenes/characters/enemy/enemy_character.tscn"

#Equipos de cada lado
var player_team = []
var enemy_team = []

func _ready():
	#TODO debug
	var players = ["testDummy","testDummy","testDummy","testDummy"]
	var enemies = ["testDummy","testDummy","testDummy","testDummy"]
	start_battle(players, enemies)

##Recibe dos arrrays con los id de los personajes que van a estar involucrados
func start_battle(player_chars, enemy_chars):
	#Incialza los nodos hijos
	battle_manager = get_node("BattleManager")
	#ID para identificar cada personaje dentro de la pelea
	var id = 0
	var new_character
	
	#Bucle para cargar los personajes del lado de jugador
	var char_position = 1
	for char_id in player_chars:
		#Calcula la posicion del personaje, el primero en cargar esta delante del todo
		new_character = create_character_from_data(char_id, id, player_char_path, char_position)
		if new_character != null:
			id+=1
			char_position+=1
			add_child(new_character)  # Add to scene tree directly instead of turn_queue
			player_team.push_front(new_character) 
		else:
			print("Something went wrong, skipping character with id:" + char_id)
			
	#Bucle para cargar los personajes del lado del enemigo
	char_position = 1
	for char_id in enemy_chars:
		#Posiciones en negativo para saber que son del lado contrario
		new_character = create_character_from_data(char_id, id, enemy_char_path, char_position)
		if new_character:
			id+=1
			char_position+=1
			add_child(new_character)  # Add to scene tree directly instead of turn_queue
			enemy_team.push_front(new_character)
		else:
			print("Something went wrong, skipping character with id:" + char_id)
	
	# No need to set teams here as BattleManager.initialize will handle this
	battle_manager.initialize(player_team, enemy_team)
	
##Recibe el id del personaje que hay cargar, el id identificador para la pelea en concreto 
##y el path de la escena a cargar
func create_character_from_data(character_data_id, fight_id, scene_path, char_position):
	#Comprueba que la escena exista
	if not FileAccess.file_exists(scene_path):
		print("Error atempting to instantiate character with path: " + scene_path + " THIS SHOULDN'T HAPPEN")
		return null
	var character_scene = load(scene_path).instantiate()
	# Configura la escena con el recurso
	if character_scene.initialize_character(character_data_id, fight_id, char_position) != null:
		return character_scene
	else:
		print("Error atempting to load character data with id: " + character_data_id + " doesn't exist")
		character_scene.queue_free()  #Elimina la escena si al final no carga
		return null

# Connect to BattleManager signals if needed
func _connect_battle_signals():
	battle_manager.battle_end.connect(_on_battle_end)
	# Connect other signals as needed
	
func _on_battle_end(winner):
	# Handle battle end
	print("Battle ended with " + winner + " victory!")
	# Additional end-of-battle logic
