extends Control

## Bus de eventos usado para comunicar entre componentes de selección de etapa
var event_bus: StageSelectionBus

## Lista de etapas desbloqueadas cargadas desde GameManager
var unlocked_stage_list: Array[StageData]

## Lista de etapas completadas, referencia directa al GameManager
var completed_stage_list: Array = GameManager.completed_stage_list

## Referencia a la etapa actualmente seleccionada
var current_selected_stage

# Referencias de nodos en escena
@onready var stage_list_display = get_node("%StageList")
@onready var stage_information_panel = get_node("%StageInformation")
@onready var options_buttons = get_node("%TopRightOptions")
@onready var character_unlocked_popup = get_node("%UnlockedCharacter")
@onready var menu_options = get_node("%OptionsPopup")

## Método principal al iniciar el nodo
func _ready() -> void:
	event_bus = StageSelectionBus.new()
	GameManager.play_music("res://audio/music/menu_music.ogg")

	# Carga los datos de las etapas desbloqueadas desde el GameManager
	for stage_id in GameManager.unlocked_stage_list:
		var unlocked_stage = StageRepo.load_stage_data_by_id(stage_id)
		if unlocked_stage != null:
			unlocked_stage_list.append(unlocked_stage)
		else:
			push_error("Unlocked stage with id: " + stage_id + " doesn't exist")
	
	# Inicializa los subcomponentes con el bus de eventos y los datos relevantes
	stage_list_display.initialize(event_bus, unlocked_stage_list, completed_stage_list)
	stage_information_panel.initialize(event_bus)
	options_buttons.initialize(event_bus)

	# Conectar señales del bus a funciones locales
	event_bus.start_button_clicked.connect(_on_start_button_clicked)
	event_bus.back_button_clicked.connect(_on_back_button_clicked)
	event_bus.stage_clicked.connect(_on_stage_clicked)
	
	# Forzar mostrar la primera misión desbloqueada (workaround provisional)
	event_bus.emit_signal("stage_clicked", unlocked_stage_list[0])

	# Muestra el popup de personajes desbloqueados si hay alguno nuevo
	if GameManager.new_chars_unlocked != [""]:
		for char_id in GameManager.new_chars_unlocked:
			var unlocked_char_data = CharacterRepo.load_character_data_by_id(char_id)
			if unlocked_char_data != null:
				character_unlocked_popup.show_character_unlock(unlocked_char_data)
				await character_unlocked_popup.popup_hide
				await get_tree().process_frame  # Esperar a que termine el frame
		GameManager.new_chars_unlocked = [""]

## Inicia el juego con la etapa seleccionada
func _on_start_button_clicked():
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	GameManager.setup_character_select(current_selected_stage.enemies, current_selected_stage.id)
	GameManager.go_to_character_select()

## Vuelve al menu principal
func _on_back_button_clicked():
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	GameManager.go_to_main_menu()

## [param stage] Etapa seleccionada por el usuario
func _on_stage_clicked(stage):
	current_selected_stage = stage

## Abre el menú de opciones
func _on_options_button_pressed() -> void:
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	menu_options.show_options_pop_up()
