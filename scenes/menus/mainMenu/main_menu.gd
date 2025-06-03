extends Control

var event_bus: MainMenuBus

@onready var main_section = get_node("%MainSection")
@onready var options_pop_up = get_node("%OptionsPopup")
@onready var lore_dump_screen = get_node("%LoreDump")

func _ready() -> void:
	event_bus = MainMenuBus.new()
	main_section.initialize(event_bus)

	event_bus.start_button_clicked.connect(_on_start_button_clicked)
	event_bus.exit_button_clicked.connect(_on_exit_button_clicked)

	await GameManager.load_game()
	if GameManager.new_save_data_created:
		lore_dump_screen.make_visible(event_bus)
		#GameManager.play_music()
		await event_bus.fade_out_lore_dump
		GameManager.new_save_data_created = false

	GameManager.play_music("res://audio/music/menu_music.ogg")
	
	var dir = DirAccess.open("res://resources/stages")
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			print("File in folder: ", file)
			file = dir.get_next()

func _on_start_button_clicked():
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	GameManager.go_to_stage_select()

func _on_exit_button_clicked():
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	get_tree().quit()

func _on_options_button_pressed() -> void:
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	options_pop_up.show_options_pop_up()
