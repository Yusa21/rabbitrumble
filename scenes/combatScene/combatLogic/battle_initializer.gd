extends Node
class_name BattleInitializer
##Clase que incializa el combate
##
##Recibe los personajes que tiene que estar involucrados en el combate y incializa el combate
##instanciando las escenas de los personajes necesarios y aportando los datos necesarios 
@onready var battle_manager: BattleManager = get_node("BattleManager")
@onready var combat_ui: BattleUIController = get_node("CanvasLayer/CombatUI")
@onready var player_team_container: Node2D = get_node("PlayerTeamContainer")
@onready var enemy_team_container: Node2D = get_node("EnemyTeamContainer")
@onready var formations_manager: FormationsManager = FormationsManager.new()
@onready var battle_event_bus: BattleEventBus = BattleEventBus.new()

#Equipos de cada lado
var player_team : Array[PlayerCharacter]
var enemy_team: Array[EnemyCharacter]

func _ready():
	formations_manager.setup(get_viewport().size)
	#TODO debug
	var players = ["testDummy","testDummy","testDummy","testDummy"]
	var enemies = ["testDummy2","testDummy2","testDummy2","testDummy2"]
	start_battle(players, enemies)

##Recibe dos arrrays con los id de los personajes que van a estar involucrados
func start_battle(player_chars, enemy_chars):

	# Limpia los equipos en caso de reinicio
	player_team.clear()
	enemy_team.clear()
	
	#ID para identificar cada personaje dentro de la pelea
	var id = 0
	var new_character: BaseCharacter
	
	#Bucle para cargar los personajes del lado de jugador
	var char_position = 1
	for char_id in player_chars:
		#Calcula la posicion del personaje, el primero en cargar esta delante del todo
		new_character = _create_character_from_data(char_id, id, BattleConstants.player_char_path, char_position)
		if new_character != null:
			id+=1
			char_position+=1
			player_team_container.add_child(new_character)
			player_team.push_front(new_character) 
		else:
			push_error("Something went wrong, skipping character with id:" + char_id)
			
	#Bucle para cargar los personajes del lado del enemigo
	char_position = 1
	for char_id in enemy_chars:
		#Posiciones en negativo para saber que son del lado contrario
		new_character = _create_character_from_data(char_id, id, BattleConstants.enemy_char_path, char_position)
		if new_character:
			id+=1
			char_position+=1
			enemy_team_container.add_child(new_character)  # Add to scene tree directly instead of turn_queue
			enemy_team.push_front(new_character)
		else:
			print("Something went wrong, skipping character with id:" + char_id)
	
	# Connect signals
	_connect_battle_signals()
	
	'''
	AQUI TIENES QUE PASAR EL BATTLE BUS TAMBIEN
	'''
	# TODO AQUI 
	battle_manager.initialize(player_team, enemy_team)
	combat_ui.initialize(battle_manager)
	
	

	
##Recibe el id del personaje que hay cargar, el id identificador para la pelea en concreto 
##y el path de la escena a cargar
func _create_character_from_data(character_data_id, fight_id, scene_path, char_position):
	#Comprueba que la escena exista
	if not FileAccess.file_exists(scene_path):
		print("Error atempting to instantiate character with path: " + scene_path + " THIS SHOULDN'T HAPPEN")
		return null
	var character_scene = load(scene_path).instantiate()
	# Configura la escena con el recurso
	if character_scene.initialize_character(character_data_id, fight_id, char_position, battle_event_bus) != null:
		#Anade el FormationManager para que los personajes puedan saber su posicion
		character_scene.set_formations_manager(formations_manager)
		return character_scene
	else:
		print("Error atempting to load character data with id: " + character_data_id + " doesn't exist")
		character_scene.queue_free()  #Elimina la escena si al final no carga
		return null

# Connect to BattleManager signals
func _connect_battle_signals():
	if battle_manager == null:
		return
		
	if not battle_event_bus.is_connected("battle_end", _on_battle_end):
		battle_event_bus.battle_end.connect(_on_battle_end)
	
func _on_battle_end(winner):
	# Handle battle end
	print("Battle ended with " + winner + " victory!")
	# Additional end-of-battle logic
