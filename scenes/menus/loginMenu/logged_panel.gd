extends VBoxContainer
class_name LoggedScreen

## Título que muestra el mensaje de bienvenida al usuario
@onready var logged_title = get_node("%LoggedTittle")
## Etiqueta para mostrar errores de sincronización o red
@onready var error_message = get_node("%LoggedError")

## Referencia al gestor de datos en línea
var save_game_data_manager
## Referencia al GameManager (padre)
var game_manager  # Reference to the parent GameManager
## Bandera que indica si se está realizando una sincronización
var is_synchronizing = false  # Flag to track sync process

## Inicializa el panel y conecta las señales del gestor de datos
## [param save_manager] Instancia del OnlineSaveDataManager
func initialize(save_manager):
	save_game_data_manager = save_manager
	game_manager = save_manager.get_parent()  # Get GameManager reference
	save_game_data_manager.get_game_data_succesful.connect(_on_get_game_data_successful)
	save_game_data_manager.update_game_data_succesful.connect(_on_update_game_data_successful)
	save_game_data_manager.request_timeout.connect(_on_request_timeout)

## Se ejecuta al presionar el botón de sincronización, descargando datos del servidor
func _on_synchronize_data_button_pressed() -> void:
	print("Starting synchronization...")
	error_message.text = ""  # Limpia errores anteriores
	is_synchronizing = true
	save_game_data_manager.get_game_data()

## Se ejecuta al presionar el botón de subir datos, enviando el progreso local al servidor
func _on_upload_data_button_pressed() -> void:
	print("Uploading current game data...")
	error_message.text = ""  # Limpia errores anteriores
	
	# Obtiene los datos actuales del GameManager
	save_game_data_manager.save_game_data(
		game_manager.unlocked_char_list,
		game_manager.unlocked_stage_list,
		game_manager.completed_stage_list
	)

## Se ejecuta cuando se descargan correctamente los datos del servidor
func _on_get_game_data_successful():
	if is_synchronizing:
		print("Game data downloaded successfully! Merging with local data...")
		merge_and_sync_data()
		is_synchronizing = false
	else:
		print("Game data downloaded successfully!")

## Fusiona los datos en línea con los datos locales y los actualiza en el servidor
func merge_and_sync_data():
	# Obtiene los datos descargados del servidor
	var online_data = save_game_data_manager.get_last_downloaded_data()
	
	if online_data == null:
		print("No online data found, uploading local data...")
		_on_upload_data_button_pressed()
		return
	
	# Copia los datos locales actuales
	var local_chars = game_manager.unlocked_char_list.duplicate()
	var local_stages = game_manager.unlocked_stage_list.duplicate()
	var local_completed = game_manager.completed_stage_list.duplicate()
	
	# Fusiona datos locales con los datos del servidor
	var merged_chars = merge_arrays(local_chars, online_data.get("unlocked_characters", []))
	var merged_stages = merge_arrays(local_stages, online_data.get("unlocked_stages", []))
	var merged_completed = merge_arrays(local_completed, online_data.get("completed_stages", []))
	
	# Actualiza los datos locales con la fusión
	game_manager.unlocked_char_list = merged_chars
	game_manager.unlocked_stage_list = merged_stages
	game_manager.completed_stage_list = merged_completed
	
	print("Local data updated with online content:")
	print("Characters: ", merged_chars)
	print("Stages: ", merged_stages)
	print("Completed: ", merged_completed)
	
	# Sube los datos fusionados al servidor
	print("Uploading merged data to server...")
	save_game_data_manager.save_game_data(merged_chars, merged_stages, merged_completed)

## Fusiona dos arrays sin duplicados
## [param local_array] Array local actual
## [param online_array] Array descargado desde el servidor
## [return] Array fusionado sin duplicados
func merge_arrays(local_array: Array, online_array: Array) -> Array:
	var merged = local_array.duplicate()
	
	for item in online_array:
		if not merged.has(item):
			merged.append(item)
			print("Added from online: ", item)
	
	return merged

## Se ejecuta al subir exitosamente los datos al servidor
func _on_update_game_data_successful():
	if is_synchronizing:
		print("Synchronization completed successfully!")
	else:
		print("Game data uploaded successfully!")

## Se ejecuta cuando hay un timeout o error de conexión
func _on_request_timeout():
	error_message.text = "Connection timeout. Please try again."
	if is_synchronizing:
		is_synchronizing = false

## Actualiza el mensaje de bienvenida con el nombre de usuario
func update_welcome_message():
	if save_game_data_manager:
		logged_title.text = "Welcome " + str(save_game_data_manager.keep_username)
	error_message.text = ""  # Limpia errores al mostrar la pantalla
