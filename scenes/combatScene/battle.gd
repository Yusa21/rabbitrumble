extends Node
class_name Battle

## Clase que inicializa el combate.
##
## Recibe los personajes que tienen que estar involucrados en el combate y inicializa el combate
## instanciando las escenas de los personajes necesarios y aportando los datos necesarios.
@onready var battle_manager
@onready var combat_ui
@onready var formations_manager
@onready var player_team_container
@onready var enemy_team_container

## Constantes para evitar datos sin explicar en mitad del codigo.
const player_char_path = preload("res://scenes/characters/player/player_character.tscn")
const enemy_char_path = preload("res://scenes/characters/enemy/enemy_character.tscn")

## Equipos de cada lado.
var player_team = []
var enemy_team = []

## Bus de eventos de batalla para la comunicacion entre componentes.
var battle_event_bus: BattleEventBus

## Funcion llamada cuando el nodo esta listo.
## Verifica si hay datos de personajes del menu e inicia la batalla.
func _ready():
	# Verifica si tenemos datos de personajes del menu
	GameManager.play_music("res://audio/music/battle_music.ogg")
	if GameManager.selected_player_characters.size() > 0 and GameManager.selected_enemy_characters.size() > 0:
		start_battle(GameManager.selected_player_characters, GameManager.selected_enemy_characters)
	else:
		push_error("Error: One of the teams is missing when trying to start the battle")

## Inicia la batalla con los personajes especificados.
## [param player_chars] Array con los IDs de los personajes del jugador.
## [param enemy_chars] Array con los IDs de los personajes enemigos.
func start_battle(player_chars, enemy_chars):
	# Inicializa los nodos hijos
	battle_manager = get_node("BattleManager")
	formations_manager = get_node("FormationManager")
	combat_ui = get_node("CanvasLayer/CombatUI")
	player_team_container = get_node("PlayerTeamContainer")
	enemy_team_container = get_node("EnemyTeamContainer")
	
	# Inicializa el bus de eventos
	battle_event_bus = BattleEventBus.new()
	
	if battle_manager == null:
		push_error("BattleManager node not found! Make sure it's a child node named 'BattleManager'")
		return
		
	# Limpia los equipos en caso de reiniciar
	player_team.clear()
	enemy_team.clear()
	
	# ID para identificar cada personaje dentro de la pelea
	var id = 0
	var new_character
	
	# Bucle para cargar los personajes del lado del jugador
	var char_position = 1
	for char_id in player_chars:
		# Calcula la posicion del personaje, el primero en cargar esta delante del todo
		new_character = create_character_from_data(char_id, id, player_char_path, char_position)
		if new_character != null:
			id+=1
			char_position+=1
			player_team_container.add_child(new_character)
			player_team.push_front(new_character) 
		else:
			print("Something went wrong, skipping character with id:" + char_id)
			
	# Bucle para cargar los personajes del lado del enemigo
	char_position = 1
	for char_id in enemy_chars:
		# Posiciones en negativo para saber que son del lado contrario
		new_character = create_character_from_data(char_id, id, enemy_char_path, char_position)
		if new_character:
			id+=1
			char_position+=1
			enemy_team_container.add_child(new_character)  # Add to scene tree directly instead of turn_queue
			enemy_team.push_front(new_character)
		else:
			print("Something went wrong, skipping character with id:" + char_id)
	
	# Asegura que todos los personajes tengan las propiedades requeridas
	ensure_character_properties()
	
	# Conecta las senales apropiadas al bus de eventos
	_connect_battle_signals()
	
	# Inicializa el battle manager con el bus de eventos
	battle_manager.initialize(player_team, enemy_team, battle_event_bus)
	combat_ui.initialize(battle_manager, battle_event_bus)

## Crea un personaje a partir de los datos proporcionados.
## [param character_data_id] ID del personaje en los datos del juego.
## [param fight_id] ID identificador para la pelea en concreto.
## [param scene_path] Ruta de la escena a cargar.
## [param char_position] Posicion del personaje en la formacion.
## [return] La instancia del personaje creado o null si falla.
func create_character_from_data(character_data_id, fight_id, scene_path, char_position):
	# Comprueba que la escena exista
	var character_scene = scene_path.instantiate()
	# Configura la escena con el recurso
	if character_scene.initialize_character(character_data_id, fight_id, char_position) != null:
		# Anade el FormationManager para que los personajes puedan saber su posicion
		character_scene.set_formations_manager(formations_manager)
		
		# Inicializa el personaje con el bus de eventos
		character_scene.initialize_with_event_bus(battle_event_bus)
		
		return character_scene
	else:
		print("Error atempting to load character data with id: " + character_data_id + " doesn't exist")
		character_scene.queue_free()  # Elimina la escena si al final no carga
		return null

## Asegura que todos los personajes tengan las propiedades requeridas para BattleManager.
func ensure_character_properties():
	for team in [player_team, enemy_team]:
		for character in team:
			# Asegura que el personaje tenga todas las propiedades requeridas
			if not "has_taken_turn" in character:
				character.has_taken_turn = false
			if not "is_defeated" in character:
				character.is_defeated = false
			if not "speed" in character:
				character.speed = 10  # Valor de velocidad por defecto
			if not "char_name" in character:
				character.char_name = "Unknown"  # Nombre por defecto

## Conecta las senales de BattleManager via el bus de eventos.
func _connect_battle_signals():
	if battle_event_bus == null:
		push_error("Event bus not initialized!")
		return
		
	# Conecta a la senal battle_end del bus de eventos
	battle_event_bus.battle_end.connect(_on_battle_end)

## Maneja el final de la batalla.
## [param winner] El ganador de la batalla ("player" o "enemy").
func _on_battle_end(winner):
	# Maneja el final de la batalla
	print("Battle ended with " + winner + " victory!")
	if winner == "player":
		GameManager.end_battle()
	else:
		GameManager.end_battle_defeat()