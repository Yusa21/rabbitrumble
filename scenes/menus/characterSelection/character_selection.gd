extends Control

var event_bus: CharacterSelectionBus
var unlocked_char_list: Array
var level_enemy_characters: Array

@onready var char_info_panel = get_node("%CharacterInfo")
@onready var char_list_panel = get_node("%CharacterList")
@onready var enemy_team_preview_panel = get_node("%EnemyTeamPreview")
@onready var player_team_preview_panel = get_node("%PlayerTeamPreview")
@onready var team_buttons = get_node("%TeamButtons")
@onready var options_buttons = get_node("%TopRightOptions")
@onready var options_menu = get_node("%OptionsPopup")

func _ready() -> void:

	#Saca los personajes desbloqueados del game manager
	for character_id in GameManager.unlocked_char_list:
		unlocked_char_list.append(CharacterRepo.load_character_data_by_id(character_id))
		print(character_id)

	#Saca los enemigos del nivel del game manager
	for character_id in GameManager.level_enemy_characters:
		level_enemy_characters.append(CharacterRepo.load_character_data_by_id(character_id))
		print(character_id)
	

	event_bus = CharacterSelectionBus.new()
	
	char_info_panel.initialize(event_bus)
	char_list_panel.initialize(event_bus, unlocked_char_list)
	enemy_team_preview_panel.initialize(event_bus, level_enemy_characters)
	player_team_preview_panel.initialize(event_bus)
	team_buttons.initialize(event_bus)
	options_buttons.initialize(event_bus)

	event_bus.start_button_clicked.connect(_on_start_button_clicked)
	event_bus.back_button_clicked.connect(_on_back_button_clicked)

	#Esto es mazo cutre pero hace que el primer personaje de la lista se ponga por defecto
	event_bus.emit_signal("character_clicked", unlocked_char_list[0])

func _on_start_button_clicked():
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	transition_to_battle()

func _on_back_button_clicked():
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	transition_to_stage_selection()

func transition_to_battle():
	var player_team: Array
	var enemy_team: Array
	
	for character in player_team_preview_panel.get_children():
		if character.has_meta("character_data"):
			var char_data = character.get_meta("character_data")
			player_team.append(char_data["character_id"])

	#Si no hay al menos un personaje en el equipo jugador no puede empezar el combate
	if player_team.size() <= 0:
		return
	else:
		for character in enemy_team_preview_panel.get_children():
			if character.has_meta("character_data"):
				var char_data = character.get_meta("character_data")
				enemy_team.append(char_data["character_id"])

		GameManager.setup_battle(player_team,enemy_team)
		GameManager.start_battle()

func transition_to_stage_selection():
	GameManager.go_to_stage_select()
	pass


func _on_options_button_pressed() -> void:
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	options_menu.show_options_pop_up()
