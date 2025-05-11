extends Control

var event_bus: CharacterSelectionBus
var unlocked_char_list: Array
var level_enemy_characters: Array

@onready var char_info_panel = get_node("%CharacterInfo")
@onready var char_list_panel = get_node("%CharacterList")
@onready var enemy_team_preview_panel = get_node("%EnemyTeamPreview")
@onready var player_team_preview_panel = get_node("%PlayerTeamPreview")

func _ready() -> void:
	for character_id in GameManager.unlocked_char_list:
		unlocked_char_list.append(CharacterRepo.load_character_data_by_id(character_id))

	for character_id in GameManager.level_enemy_characters:
		level_enemy_characters.append(CharacterRepo.load_character_data_by_id(character_id))
	

	event_bus = CharacterSelectionBus.new()
	char_info_panel.initialize(event_bus)
	char_list_panel.initialize(event_bus, unlocked_char_list)
	enemy_team_preview_panel.initialize(event_bus, level_enemy_characters)
	player_team_preview_panel.initialize(event_bus)

	#Esto es mazo cutre pero hace que el primer personaje de la lista se ponga por defecto
	event_bus.emit_signal("character_clicked", unlocked_char_list[0])
