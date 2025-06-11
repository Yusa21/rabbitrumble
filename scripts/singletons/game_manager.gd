## Singleton principal del juego que maneja datos de usuario, audio y transiciones.
## Este nodo se encarga de gestionar el estado global del juego incluyendo
## personajes desbloqueados, escenarios completados, sistema de audio y
## transiciones entre escenas.
extends Node

#---------------------DATOS DE USUARIO-------------------------------------------------------

## Lista de personajes desbloqueados disponibles para el jugador.
var unlocked_char_list = ["testDummy","testDummy2","p_c_001","p_c_004","p_c_005","p_c_006"]

## Lista de escenarios que el jugador ha desbloqueado.
var unlocked_stage_list = ["test_stage", "test_stage_2"]

## Lista de escenarios que el jugador ha completado exitosamente.
var completed_stage_list = ["test_stage"]

## Indica si se ha creado un nuevo archivo de guardado en esta sesion.
var new_save_data_created = false

#---------------------SISTEMA DE AUDIO----------------------------------------------------

## Diccionario que rastrea el ultimo momento de reproduccion de cada efecto de sonido.
var sfx_last_play_time: Dictionary = {}

## Tiempo de espera minimo entre reproducciones del mismo efecto de sonido en segundos.
var sfx_cooldown: float = 0.1

## Reproductor de audio principal para la musica de fondo.
var music_player: AudioStreamPlayer

## Array de reproductores de audio para efectos de sonido simultaneos.
var sfx_players: Array[AudioStreamPlayer] = []

## Nombre de la pista de musica actualmente en reproduccion.
var current_track: String = ""

## Nombre del bus de audio para la musica.
var music_bus: String = "Music"

## Nombre del bus de audio para los efectos de sonido.
var sfx_bus: String = "SFX"

## Volumen de la musica en decibelios (0.0 dB es el volumen por defecto).
var music_volume: float = 0.0

## Volumen de los efectos de sonido en decibelios.
var sfx_volume: float = 0.0

## Volumen maestro en decibelios.
var master_volume: float = 0.0

## Diccionario para precargar musica y mejorar el rendimiento.
var preloaded_music: Dictionary = {}

## Inicializa el sistema de audio cuando el singleton se carga.
func _ready():
	# Crear el reproductor de musica cuando el singleton se carga
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	setup_audio_buses()
	apply_volume_settings()
	
	# Crear un pool de reproductores de efectos de sonido
	for i in range(8):  # Pool de 8 reproductores de efectos
		var sfx = AudioStreamPlayer.new()
		sfx.bus = sfx_bus
		add_child(sfx)
		sfx_players.append(sfx)
	
	# Cargar configuracion de audio guardada
	load_audio_settings()

## Configura la estructura de buses de audio si no existe.
func setup_audio_buses():
	var audio_bus_count = AudioServer.bus_count
	
	# Verificar si nuestros buses existen
	var has_music_bus = false
	var has_sfx_bus = false
	
	for i in range(audio_bus_count):
		var bus_name = AudioServer.get_bus_name(i)
		if bus_name == music_bus:
			has_music_bus = true
		elif bus_name == sfx_bus:
			has_sfx_bus = true
	
	# Crear buses si no existen
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

## Aplica la configuracion de volumen a los buses de audio.
func apply_volume_settings():
	# Volumen Maestro
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_volume)
	
	# Volumen de Musica
	var music_bus_idx = AudioServer.get_bus_index(music_bus)
	if music_bus_idx >= 0:
		AudioServer.set_bus_volume_db(music_bus_idx, music_volume)
	
	# Volumen de Efectos de Sonido
	var sfx_bus_idx = AudioServer.get_bus_index(sfx_bus)
	if sfx_bus_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_bus_idx, sfx_volume)

## Establece el volumen maestro en decibelios.
## [param value_db] Valor del volumen en decibelios, limitado entre -80.0 y 6.0.
func set_master_volume(value_db: float):
	master_volume = clamp(value_db, -80.0, 6.0)
	apply_volume_settings()
	save_audio_settings()

## Establece el volumen de la musica en decibelios.
## [param value_db] Valor del volumen en decibelios, limitado entre -80.0 y 6.0.
func set_music_volume(value_db: float):
	music_volume = clamp(value_db, -80.0, 6.0)
	apply_volume_settings()
	save_audio_settings()

## Establece el volumen de los efectos de sonido en decibelios.
## [param value_db] Valor del volumen en decibelios, limitado entre -80.0 y 6.0.
func set_sfx_volume(value_db: float):
	sfx_volume = clamp(value_db, -80.0, 6.0)
	apply_volume_settings()
	save_audio_settings()

## Convierte un valor lineal (0.0-1.0) a escala de decibelios para sliders de interfaz.
## [param linear_value] Valor lineal entre 0.0 y 1.0.
## [return] Valor equivalente en decibelios.
func linear_to_db(linear_value: float) -> float:
	if linear_value <= 0:
		return -80.0
	return 20.0 * log(linear_value) / log(10.0)

## Convierte un valor en decibelios a escala lineal (0.0-1.0).
## [param db_value] Valor en decibelios.
## [return] Valor lineal equivalente.
func db_to_linear(db_value: float) -> float:
	return pow(10.0, db_value / 20.0)

## Establece el volumen maestro usando un porcentaje (0-100%).
## [param percent] Porcentaje del volumen entre 0 y 100.
func set_master_volume_percent(percent: float):
	var linear = percent / 100.0
	set_master_volume(linear_to_db(linear))

## Establece el volumen de musica usando un porcentaje (0-100%).
## [param percent] Porcentaje del volumen entre 0 y 100.
func set_music_volume_percent(percent: float):
	var linear = percent / 100.0
	set_music_volume(linear_to_db(linear))

## Establece el volumen de efectos usando un porcentaje (0-100%).
## [param percent] Porcentaje del volumen entre 0 y 100.
func set_sfx_volume_percent(percent: float):
	var linear = percent / 100.0
	set_sfx_volume(linear_to_db(linear))

## Obtiene el volumen maestro actual como porcentaje (0-100).
## [return] Volumen maestro en porcentaje.
func get_master_volume_percent() -> float:
	return db_to_linear(master_volume) * 100.0

## Obtiene el volumen de musica actual como porcentaje (0-100).
## [return] Volumen de musica en porcentaje.
func get_music_volume_percent() -> float:
	return db_to_linear(music_volume) * 100.0

## Obtiene el volumen de efectos actual como porcentaje (0-100).
## [return] Volumen de efectos en porcentaje.
func get_sfx_volume_percent() -> float:
	return db_to_linear(sfx_volume) * 100.0

## Reproduce una pista de musica con opcion de fundido cruzado.
## [param track_path] Ruta del archivo de musica a reproducir.
## [param crossfade] Si debe aplicar fundido cruzado entre pistas.
## [param fade_duration] Duracion del efecto de fundido en segundos.
func play_music(track_path: String, crossfade: bool = true, fade_duration: float = 1.0):
	if current_track == track_path and music_player.playing:
		return # Ya esta reproduciendo esta pista
	
	# Precargar la pista si es necesario
	var music_stream
	if preloaded_music.has(track_path):
		music_stream = preloaded_music[track_path]
	else:
		music_stream = load(track_path)
		
	if music_stream == null:
		push_error("Could not load music track: " + track_path)
		return
		
	if crossfade and music_player.playing:
		# Crear un efecto de fundido
		var old_player = music_player
		var _initial_volume = old_player.volume_db
		
		# Crear nuevo reproductor para la nueva pista
		music_player = AudioStreamPlayer.new()
		music_player.bus = music_bus
		add_child(music_player)
		
		# Cargar y reproducir nueva pista (comenzando en silencio)
		music_player.stream = music_stream
		music_player.volume_db = -80.0
		music_player.play()
		
		# Subir volumen de nueva pista mientras baja el de la anterior
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", 0.0, fade_duration)
		tween.parallel().tween_property(old_player, "volume_db", -80.0, fade_duration)
		tween.tween_callback(func(): 
			old_player.stop()
			old_player.queue_free()
		)
	else:
		# Reproduccion simple sin fundido cruzado
		music_player.stop()
		music_player.stream = music_stream
		music_player.play()
	
	current_track = track_path

	if music_stream is AudioStream:
		music_stream.loop = true

## Detiene la reproduccion de musica con opcion de fundido.
## [param fade_duration] Duracion del efecto de fundido en segundos.
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

## Pausa la reproduccion de musica actual.
func pause_music():
	if music_player.playing:
		music_player.stream_paused = true

## Reanuda la reproduccion de musica pausada.
func resume_music():
	if music_player.stream_paused:
		music_player.stream_paused = false

## Precarga pistas de musica en memoria para mejor rendimiento.
## [param track_paths] Array con las rutas de las pistas a precargar.
func preload_music(track_paths: Array[String]):
	for path in track_paths:
		if not preloaded_music.has(path):
			var stream = load(path)
			if stream:
				preloaded_music[path] = stream

## Limpia todas las pistas de musica precargadas de la memoria.
func clear_preloaded_music():
	preloaded_music.clear()

## Reproduce un efecto de sonido con parametros personalizables.
## [param sfx_path] Ruta del archivo de efecto de sonido.
## [param volume_db] Volumen del efecto en decibelios.
## [param pitch_scale] Escala de tono del efecto (1.0 es normal).
## [return] El reproductor de audio usado, o null si no se pudo reproducir.
func play_sfx(sfx_path: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> AudioStreamPlayer:
	var current_time = Time.get_ticks_msec() / 1000.0  # segundos
	
	# Verificar tiempo de espera
	if sfx_last_play_time.has(sfx_path):
		var last_time = sfx_last_play_time[sfx_path]
		if current_time - last_time < sfx_cooldown:
			return null  # Aun en tiempo de espera
	
	sfx_last_play_time[sfx_path] = current_time
	
	# Encontrar un reproductor disponible
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

## Busca un reproductor de efectos de sonido disponible en el pool.
## [return] Un reproductor disponible o el primero del pool si todos estan ocupados.
func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
			
	return sfx_players[0]

## Guarda la configuracion de audio actual en un archivo.
func save_audio_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	
	var err = config.save("user://audio_settings.cfg")
	if err != OK:
		push_error("Failed to save audio settings")

## Carga la configuracion de audio desde archivo o usa valores por defecto.
func load_audio_settings():
	var config = ConfigFile.new()
	var err = config.load("user://audio_settings.cfg")
	
	if err == OK:
		master_volume = config.get_value("audio", "master_volume", 0.0)
		music_volume = config.get_value("audio", "music_volume", 0.0)
		sfx_volume = config.get_value("audio", "sfx_volume", 0.0)
		apply_volume_settings()
	else:
		# Usar valores por defecto
		master_volume = 0.0
		music_volume = 0.0
		sfx_volume = 0.0
		apply_volume_settings()

#----------------------ANIMACIONES DE TRANSICION------------------------------------------

## Referencia al rectangulo de color usado para las transiciones entre escenas.
@onready var transition_rect = get_node("TransitionColorRect")

## Anima una transicion deslizandose desde la derecha hacia el centro.
func slide_in_from_right():
	# Posicionar fuera de pantalla a la derecha, hacer visible, luego deslizar hacia adentro
	transition_rect.position.x = get_viewport().size.x
	transition_rect.visible = true
	
	var tween = create_tween()
	tween.tween_property(transition_rect, "position:x", 0, 1)
	await tween.finished

## Anima una transicion deslizandose desde la izquierda hacia el centro.
func slide_in_from_left():
	# Posicionar fuera de pantalla a la izquierda, hacer visible, luego deslizar hacia adentro
	transition_rect.position.x = -get_viewport().size.x
	transition_rect.visible = true
	
	var tween = create_tween()
	tween.tween_property(transition_rect, "position:x", 0, 1)
	await tween.finished

## Anima una transicion deslizandose desde el centro hacia la derecha.
func slide_out_to_right():
	print("Starting slide in from right")
	transition_rect.position.x = get_viewport().size.x
	transition_rect.visible = true
	print("Rect position: ", transition_rect.position)
	
	var tween = create_tween()
	tween.tween_property(transition_rect, "position:x", 0, 1.0)  # Mas lento para pruebas
	await tween.finished
	print("Slide in completed")

## Anima una transicion deslizandose desde el centro hacia la izquierda.
func slide_out_to_left():
	var tween = create_tween()
	tween.tween_property(transition_rect, "position:x", -get_viewport().size.x, 1)
	await tween.finished
	transition_rect.visible = false

#----------------------TRANSICION AL MENU PRINCIPAL-------------------------------------------

## Cambia la escena actual al menu principal del juego.
func go_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/menus/mainMenu/main_menu.tscn")

#----------------------TRANSICION A SELECCION DE ESCENARIO-------------------------------------

## Array que almacena los nuevos personajes desbloqueados en la ultima batalla.
var new_chars_unlocked: Array[String]

## Cambia la escena actual a la seleccion de escenarios.
func go_to_stage_select():
	get_tree().change_scene_to_file("res://scenes/menus/stageSelection/stage_selection.tscn")

#----------------------TRANSICION A SELECCION DE PERSONAJE---------------------------------

## ID del escenario actualmente seleccionado.
var stage_id = ["test_stage"]

## Lista de personajes enemigos para el nivel actual.
var level_enemy_characters = ["testDummy2","testDummy2","testDummy2","testDummy2"]

## Configura los datos necesarios para la seleccion de personajes.
## [param level_enemies] Array con los IDs de los enemigos del nivel.
## [param id] ID del escenario seleccionado.
func setup_character_select(level_enemies, id):
	level_enemy_characters = level_enemies
	print(level_enemy_characters)
	stage_id = id

## Cambia la escena actual a la seleccion de personajes.
func go_to_character_select():
	get_tree().change_scene_to_file("res://scenes/menus/characterSelection/character_selection.tscn")

#---------------------TRANSICION DE DATOS DE BATALLA------------------------------------------

## Array con los personajes seleccionados por el jugador para la batalla.
var selected_player_characters = ["testDummy","testDummy","testDummy","testDummy"]

## Array con los personajes enemigos para la batalla.
var selected_enemy_characters = ["testDummy2","testDummy2","testDummy2","testDummy2"]

## Configura una nueva batalla con los personajes especificados.
## [param players] Array con los IDs de los personajes del jugador.
## [param enemies] Array con los IDs de los personajes enemigos.
func setup_battle(players, enemies):
	print(players)
	print(enemies)
	selected_player_characters = players
	selected_enemy_characters = enemies

## Inicia la escena de batalla con los personajes configurados.
func start_battle():
	# Transicion a la escena de batalla
	get_tree().change_scene_to_file("res://scenes/combatScene/Battle.tscn")

## Finaliza la batalla con victoria, marca el escenario como completado y verifica desbloqueos.
func end_battle():
	mark_stage_as_completed()
	check_unlocks()
	save_game()
	go_to_stage_select()

## Finaliza la batalla con derrota y regresa a la seleccion de escenarios.
func end_battle_defeat():
	go_to_stage_select()

## Marca el escenario actual como completado si no lo estaba ya.
func mark_stage_as_completed():
	if !completed_stage_list.has(stage_id):
		completed_stage_list.append(stage_id)

## Verifica y aplica desbloqueos de personajes y escenarios segun el escenario completado.
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

#-----------------------------GESTION DE DATOS DE GUARDADO--------------------------------

## Guarda el estado actual del juego en un archivo de recursos.
## [return] true si el guardado fue exitoso, false en caso contrario.
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

## Carga el estado del juego desde archivo o crea uno nuevo si no existe.
## [return] true si la carga fue exitosa, false en caso contrario.
func load_game():
	if not FileAccess.file_exists("user://save_game.tres"):
		create_default_save_file()
		return true
		
	var save_data = load("user://save_game.tres")
	if not save_data:
		push_error("Failed to load save file")
		return false

	# Crear nuevas copias modificables de los arrays
	unlocked_char_list = save_data.unlocked_char_list.duplicate()
	unlocked_stage_list = save_data.unlocked_stage_list.duplicate()
	completed_stage_list = save_data.completed_stage_list.duplicate()

	print("Loaded game")

	return true

## Lista por defecto de personajes desbloqueados para nuevas partidas.
#const default_char_list: Array[String] = ["p_c_001","p_c_002","p_c_003","p_c_004", "p_c_005" ,"p_c_006","p_c_007"]
const default_char_list: Array[String] = ["p_c_007"]

## Lista por defecto de escenarios desbloqueados para nuevas partidas.
const default_stage_list: Array[String] = ["stage_1"]

## Lista por defecto de escenarios completados para nuevas partidas.
const default_completed_list: Array[String] = []

## Crea un archivo de guardado con valores por defecto para nuevas partidas.
## [return] true si la creacion fue exitosa, false en caso contrario.
func create_default_save_file():
	var save_data = GameSave.new()

	save_data.unlocked_char_list = default_char_list.duplicate()
	save_data.unlocked_stage_list = default_stage_list.duplicate()
	save_data.completed_stage_list = default_completed_list.duplicate()

	var error = ResourceSaver.save(save_data, "user://save_game.tres")
	if error != OK:
		push_error("Failed to create new save file: ", error)
		return false

	unlocked_char_list = default_char_list.duplicate()
	unlocked_stage_list = default_stage_list.duplicate()
	completed_stage_list = default_completed_list.duplicate()

	new_save_data_created = true

	print("Save file created")