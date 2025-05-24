extends Node
#---------------------USER DATA-------------------------------------------------------
var unlocked_char_list = ["testDummy","testDummy2","p_c_003","p_c_004","p_c_005","p_c_006"]
var unlocked_stage_list = ["test_stage", "test_stage_2"]
var completed_stage_list = ["test_stage"]

#---------------------AUDIO SYSTEM----------------------------------------------------
# Audio nodes
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var current_track: String = ""

# Audio buses
var music_bus: String = "Music"
var sfx_bus: String = "SFX"

# Volume settings (in dB)
var music_volume: float = 0.0  # 0.0 dB is default volume (1.0 linear)
var sfx_volume: float = 0.0
var master_volume: float = 0.0

# Music preloading for performance
var preloaded_music: Dictionary = {}

# Initialize the audio system
func _ready():
	# Create the music player when the singleton loads
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	setup_audio_buses()
	apply_volume_settings()
	
	# Create a pool of SFX players
	for i in range(8):  # Pool of 8 SFX players
		var sfx = AudioStreamPlayer.new()
		sfx.bus = sfx_bus
		add_child(sfx)
		sfx_players.append(sfx)
	
	# Load saved audio settings
	load_audio_settings()

# Set up audio bus structure if it doesn't exist
func setup_audio_buses():
	var audio_bus_count = AudioServer.bus_count
	
	# Check if our buses exist
	var has_music_bus = false
	var has_sfx_bus = false
	
	for i in range(audio_bus_count):
		var bus_name = AudioServer.get_bus_name(i)
		if bus_name == music_bus:
			has_music_bus = true
		elif bus_name == sfx_bus:
			has_sfx_bus = true
	
	# Create buses if they don't exist
	if not has_music_bus:
		AudioServer.add_bus()
		var music_bus_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(music_bus_idx, music_bus)
		AudioServer.set_bus_send(music_bus_idx, "Master")
		music_player.bus = music_bus
	else:
		music_player.bus = music_bus
		
	if not has_sfx_bus:
		AudioServer.add_bus()
		var sfx_bus_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(sfx_bus_idx, sfx_bus)
		AudioServer.set_bus_send(sfx_bus_idx, "Master")
		
		for player in sfx_players:
			player.bus = sfx_bus

# Apply volume settings to audio buses
func apply_volume_settings():
	# Master Volume
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume)
	
	# Music Volume
	var music_bus_idx = AudioServer.get_bus_index(music_bus)
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, music_volume)
	
	# SFX Volume
	var sfx_bus_idx = AudioServer.get_bus_index(sfx_bus)
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, sfx_volume)

# Volume control methods
func set_master_volume(value_db: float):
	master_volume = clamp(value_db, -80.0, 6.0)
	apply_volume_settings()
	save_audio_settings()
	
func set_music_volume(value_db: float):
	music_volume = clamp(value_db, -80.0, 6.0)
	apply_volume_settings()
	save_audio_settings()
	
func set_sfx_volume(value_db: float):
	sfx_volume = clamp(value_db, -80.0, 6.0)
	apply_volume_settings()
	save_audio_settings()

# Convert between linear (0.0-1.0) and decibel scales for UI sliders
func linear_to_db(linear_value: float) -> float:
	if linear_value <= 0:
		return -80.0
	return 20.0 * log(linear_value) / log(10.0)
	
func db_to_linear(db_value: float) -> float:
	return pow(10.0, db_value / 20.0)
	
# Set volume from a 0-100% slider
func set_master_volume_percent(percent: float):
	var linear = percent / 100.0
	set_master_volume(linear_to_db(linear))
	
func set_music_volume_percent(percent: float):
	var linear = percent / 100.0
	set_music_volume(linear_to_db(linear))
	
func set_sfx_volume_percent(percent: float):
	var linear = percent / 100.0
	set_sfx_volume(linear_to_db(linear))
	
# Get current volume as percentage (0-100)
func get_master_volume_percent() -> float:
	return db_to_linear(master_volume) * 100.0
	
func get_music_volume_percent() -> float:
	return db_to_linear(music_volume) * 100.0
	
func get_sfx_volume_percent() -> float:
	return db_to_linear(sfx_volume) * 100.0

# Music playback methods
func play_music(track_path: String, crossfade: bool = true, fade_duration: float = 1.0):
	if current_track == track_path and music_player.playing:
		return # Already playing this track
	
	# Preload the track if needed
	var music_stream
	if preloaded_music.has(track_path):
		music_stream = preloaded_music[track_path]
	else:
		music_stream = load(track_path)
		
	if music_stream == null:
		push_error("Could not load music track: " + track_path)
		return
		
	if crossfade and music_player.playing:
		# Create a fading effect
		var old_player = music_player
		var initial_volume = old_player.volume_db
		
		# Create new player for the new track
		music_player = AudioStreamPlayer.new()
		music_player.bus = music_bus
		add_child(music_player)
		
		# Load and play new track (starting silent)
		music_player.stream = music_stream
		music_player.volume_db = -80.0
		music_player.play()
		
		# Fade in new track while fading out old track
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", 0.0, fade_duration)
		tween.parallel().tween_property(old_player, "volume_db", -80.0, fade_duration)
		tween.tween_callback(func(): 
			old_player.stop()
			old_player.queue_free()
		)
	else:
		# Simple play without crossfade
		music_player.stop()
		music_player.stream = music_stream
		music_player.play()
	
	current_track = track_path

	if music_stream is AudioStream:
		music_stream.loop = true

func stop_music(fade_duration: float = 1.0):
	if not music_player.playing:
		return
		
	if fade_duration > 0:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_duration)
		tween.tween_callback(music_player.stop)
	else:
		music_player.stop()
	
	current_track = ""

func pause_music():
	if music_player.playing:
		music_player.stream_paused = true
		
func resume_music():
	if music_player.stream_paused:
		music_player.stream_paused = false

# Music preloading
func preload_music(track_paths: Array[String]):
	for path in track_paths:
		if not preloaded_music.has(path):
			var stream = load(path)
			if stream:
				preloaded_music[path] = stream
				
func clear_preloaded_music():
	preloaded_music.clear()

# Sound effect methods
func play_sfx(sfx_path: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> AudioStreamPlayer:
	# Find an available player
	var player = _get_available_sfx_player()
	if not player:
		print("Warning: No available SFX players!")
		return null
		
	var sfx_stream = load(sfx_path)
	if not sfx_stream:
		push_error("Could not load SFX: " + sfx_path)
		return null
		
	player.stream = sfx_stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()
	
	return player
	
func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
			
	# If all players are busy, use the oldest one
	# (This is a simple approach - you could use more sophisticated prioritization)
	return sfx_players[0]

# Save/load audio settings
func save_audio_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	
	var err = config.save("user://audio_settings.cfg")
	if err != OK:
		push_error("Failed to save audio settings")
		
func load_audio_settings():
	var config = ConfigFile.new()
	var err = config.load("user://audio_settings.cfg")
	
	if err == OK:
		master_volume = config.get_value("audio", "master_volume", 0.0)
		music_volume = config.get_value("audio", "music_volume", 0.0)
		sfx_volume = config.get_value("audio", "sfx_volume", 0.0)
		apply_volume_settings()
	else:
		# Use defaults
		master_volume = 0.0
		music_volume = 0.0
		sfx_volume = 0.0
		apply_volume_settings()

#----------------------MAIN MENU TRANSITION-------------------------------------------
func go_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/menus/mainMenu/main_menu.tscn")

#----------------------STAGE SELECTION TRANSITION-------------------------------------
var new_chars_unlocked: Array[String]
func go_to_stage_select():
	get_tree().change_scene_to_file("res://scenes/menus/stageSelection/stage_selection.tscn")

#----------------------CHARACTER SELECTION TRANSITION---------------------------------
var stage_id = ["test_stage"]
var level_enemy_characters = ["testDummy2","testDummy2","testDummy2","testDummy2"]

func setup_character_select(level_enemies, id):
	level_enemy_characters = level_enemies
	print(level_enemy_characters)
	stage_id = id

func go_to_character_select():
	get_tree().change_scene_to_file("res://scenes/menus/characterSelection/character_selection.tscn")

#---------------------BATTLE DATA TRANSITION------------------------------------------
# Data that will be passed from menu to battle
var selected_player_characters = ["testDummy","testDummy","testDummy","testDummy"]
var selected_enemy_characters = ["testDummy2","testDummy2","testDummy2","testDummy2"]

# Function to set up a new battle
func setup_battle(players, enemies):
	print(players)
	print(enemies)
	selected_player_characters = players
	selected_enemy_characters = enemies
	
# Function to start the battle scene
func start_battle():
	# Transition to battle scene
	get_tree().change_scene_to_file("res://scenes/combatScene/Battle.tscn")
	
func end_battle():
	mark_stage_as_completed()
	check_unlocks()
	save_game()
	go_to_stage_select()

func end_battle_defeat():
	go_to_stage_select()
	
func mark_stage_as_completed():
	if !completed_stage_list.has(stage_id):
		completed_stage_list.append(stage_id)
		
func check_unlocks():
	var stage_data = StageRepo.load_stage_data_by_id(stage_id)
	if stage_data.char_unlocks != [""]:
		for char_id in stage_data.char_unlocks:
			if !char_id in unlocked_char_list:
				new_chars_unlocked.append(char_id)
				unlocked_char_list.append(char_id)
   
	if stage_data.stage_unlocks != [""]:
		for unlocked_stage_id in stage_data.stage_unlocks:
			print("TRYING TO UNLOCK STAGE WITH ID:" + unlocked_stage_id)
			if !unlocked_stage_id in unlocked_stage_list:
				print("TRYING TO ADD THE STAGE")
				unlocked_stage_list.append(unlocked_stage_id)
				print(unlocked_stage_list)

#-----------------------------SAVE DATA MANAGEMENT--------------------------------
func save_game():
	var save_data = GameSave.new()
	save_data.unlocked_char_list = unlocked_char_list.duplicate()
	save_data.unlocked_stage_list = unlocked_stage_list.duplicate()
	save_data.completed_stage_list = completed_stage_list.duplicate()

	var error = ResourceSaver.save(save_data, "user://save_game.tres")
	if error != OK:
		push_error("Failed to save game: ", error)
		return false
	return true


func load_game():
	if not FileAccess.file_exists("user://save_game.tres"):
		create_default_save_file()
		return true
		
	var save_data = load("user://save_game.tres")
	if not save_data:
		push_error("Failed to load save file")
		return false

	# Create new modifiable copies of the arrays
	unlocked_char_list = save_data.unlocked_char_list.duplicate()
	unlocked_stage_list = save_data.unlocked_stage_list.duplicate()
	completed_stage_list = save_data.completed_stage_list.duplicate()

	print("Loaded game")

	return true

#const default_char_list: Array[String] = ["p_c_001","p_c_002","p_c_003","p_c_004", "p_c_005" ,"p_c_006","p_c_007"]
const default_char_list: Array[String] = ["p_c_007"]
const default_stage_list: Array[String] = ["test_stage"]
const default_completed_list: Array[String] = [""]

func create_default_save_file():
	var save_data = GameSave.new()
	# Use duplicate() to ensure we're using new modifiable arrays
	save_data.unlocked_char_list = default_char_list.duplicate()
	save_data.unlocked_stage_list = default_stage_list.duplicate()
	save_data.completed_stage_list = default_completed_list.duplicate()

	var error = ResourceSaver.save(save_data, "user://save_game.tres")
	if error != OK:
		push_error("Failed to create new save file: ", error)
		return false

	# Make sure we have modifiable copies here too
	unlocked_char_list = default_char_list.duplicate()
	unlocked_stage_list = default_stage_list.duplicate()
	completed_stage_list = default_completed_list.duplicate()

	print("Save file created")
