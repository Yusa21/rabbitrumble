extends Control

## Referencia al bus de eventos del menú principal
var event_bus: MainMenuBus

## Nodos de la interfaz
@onready var main_section = get_node("%MainSection")             ## Sección principal del menú
@onready var options_pop_up = get_node("%OptionsPopup")          ## Ventana emergente de opciones
@onready var lore_dump_screen = get_node("%LoreDump")            ## Pantalla que muestra la historia inicial

func _ready() -> void:
	# Inicializa el bus de eventos y conecta señales relevantes
	event_bus = MainMenuBus.new()
	main_section.initialize(event_bus)

	event_bus.start_button_clicked.connect(_on_start_button_clicked)
	event_bus.exit_button_clicked.connect(_on_exit_button_clicked)

	# Carga los datos del juego y, si es un nuevo guardado, muestra la historia inicial
	await GameManager.load_game()
	if GameManager.new_save_data_created:
		lore_dump_screen.make_visible(event_bus)
		# Espera a que termine la pantalla de historia inicial antes de continuar
		await event_bus.fade_out_lore_dump
		GameManager.new_save_data_created = false

	# Inicia la música de menú
	GameManager.play_music("res://audio/music/menu_music.ogg")

	# Debug: imprime los archivos en la carpeta de escenarios
	var dir = DirAccess.open("res://resources/stages")
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			print("File in folder: ", file)
			file = dir.get_next()

## Se ejecuta cuando se presiona el botón de "Start"
func _on_start_button_clicked():
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	GameManager.go_to_stage_select()

## Se ejecuta cuando se presiona el botón de "Exit"
func _on_exit_button_clicked():
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	get_tree().quit()

## Se ejecuta cuando se presiona el botón de "Options"
func _on_options_button_pressed() -> void:
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	options_pop_up.show_options_pop_up()
