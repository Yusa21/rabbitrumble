extends Control

## Variable que referencia al bus de eventos para la seleccion de personajes.
var event_bus: CharacterSelectionBus

## Lista de personajes desbloqueados disponibles.
var unlocked_char_list: Array

## Lista de personajes enemigos para el nivel actual.
var level_enemy_characters: Array

## Referencias a nodos hijos del Control

@onready var char_info_panel = get_node("%CharacterInfo")
@onready var char_list_panel = get_node("%CharacterList")
@onready var enemy_team_preview_panel = get_node("%EnemyTeamPreview")
@onready var player_team_preview_panel = get_node("%PlayerTeamPreview")
@onready var team_buttons = get_node("%TeamButtons")
@onready var options_buttons = get_node("%TopRightOptions")
@onready var options_menu = get_node("%OptionsPopup")

## Inicializa el controlador cargando los personajes desbloqueados y enemigos, 
## configura los paneles y conecta las señales del bus de eventos.
func _ready() -> void:

	# Obtiene los personajes desbloqueados del game manager y los carga.
	for character_id in GameManager.unlocked_char_list:
		unlocked_char_list.append(CharacterRepo.load_character_data_by_id(character_id))
		print(character_id)

	# Obtiene los personajes enemigos del nivel actual del game manager y los carga.
	for character_id in GameManager.level_enemy_characters:
		level_enemy_characters.append(CharacterRepo.load_character_data_by_id(character_id))
		print(character_id)
	
	# Crea una nueva instancia del bus de eventos para la seleccion de personajes.
	event_bus = CharacterSelectionBus.new()
	
	# Inicializa los paneles con el bus de eventos y las listas correspondientes.
	char_info_panel.initialize(event_bus)
	char_list_panel.initialize(event_bus, unlocked_char_list)
	enemy_team_preview_panel.initialize(event_bus, level_enemy_characters)
	player_team_preview_panel.initialize(event_bus)
	team_buttons.initialize(event_bus)
	options_buttons.initialize(event_bus)

	# Conecta las señales de botones de inicio y regreso a los metodos correspondientes.
	event_bus.start_button_clicked.connect(_on_start_button_clicked)
	event_bus.back_button_clicked.connect(_on_back_button_clicked)

	# Esto es simple pero pone por defecto el primer personaje de la lista como seleccionado.
	event_bus.emit_signal("character_clicked", unlocked_char_list[0])

## Metodo llamado cuando se presiona el boton de inicio.
func _on_start_button_clicked():
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	transition_to_battle()

## Metodo llamado cuando se presiona el boton de regreso.
func _on_back_button_clicked():
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	transition_to_stage_selection()

## Transiciona a la escena de batalla preparando los equipos de jugador y enemigo.
func transition_to_battle():
	var player_team: Array
	var enemy_team: Array
	
	# Construye la lista de personajes del equipo jugador desde la vista previa.
	for character in player_team_preview_panel.get_children():
		if character.has_meta("character_data"):
			var char_data = character.get_meta("character_data")
			player_team.append(char_data["character_id"])

	# Si no hay personajes en el equipo jugador no se inicia la batalla.
	if player_team.size() <= 0:
		return
	else:
		# Construye la lista de personajes del equipo enemigo desde la vista previa.
		for character in enemy_team_preview_panel.get_children():
			if character.has_meta("character_data"):
				var char_data = character.get_meta("character_data")
				enemy_team.append(char_data["character_id"])

		# Configura y comienza la batalla en el GameManager.
		GameManager.setup_battle(player_team,enemy_team)
		GameManager.start_battle()

## Transiciona a la escena de seleccion de nivel.
func transition_to_stage_selection():
	GameManager.go_to_stage_select()
	pass

## Metodo llamado cuando se presiona el boton de opciones.
func _on_options_button_pressed() -> void:
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	options_menu.show_options_pop_up()
