extends Node
class_name OnlineSaveDataManager

## Nodo de solicitud HTTP
@onready var http_request = get_node("HTTPRequest")
## Temporizador para manejar tiempo de espera
@onready var timeout_timer = Timer.new()
## Pantalla de carga (bloquea interacción)
@onready var loading_wall = get_node("%LoadingWall")
## Círculo giratorio de carga
@onready var loading_circle = get_node("%LoadingCircle")

## Token de autenticación JWT tras login
var auth_token: String = ""
## Nombre de usuario guardado tras login exitoso
var keep_username: String = ""
## Contraseña guardada tras login exitoso
var keep_password: String

## URL base del servidor
var base_url: String = "https://api999rabbits.onrender.com"
#var base_url: String = "http://localhost:8080"
## Últimos datos descargados para sincronización
var last_downloaded_data = null

# Señales emitidas por el sistema
signal login_succesful
signal login_unsuccesful
signal register_successful
signal register_username_conflict
signal get_game_data_succesful()
signal update_game_data_succesful()
signal request_timeout()  ## Emitida al superar el tiempo de espera

## Tipos de solicitudes que se pueden realizar
enum RequestType {
	LOGIN,
	REGISTER,
	GET_DATA,
	SAVE_DATA
}

## Tipo de solicitud actual
var current_request_type: RequestType
## Indica si hay una solicitud activa
var is_loading: bool = false
## Almacena solicitud fallida para reintentar después del re-login
var pending_retry_request = null

## Almacena temporalmente los datos de guardado para reintentar
var retry_unlocked_characters: Array[String] = []
var retry_unlocked_stages: Array[String] = []
var retry_completed_stages: Array[String] = []

## Inicialización del nodo al entrar en escena
func _ready() -> void:
	add_child(timeout_timer)
	timeout_timer.wait_time = 30.0
	timeout_timer.one_shot = true
	timeout_timer.timeout.connect(_on_request_timeout)
	setup_loading_system()

## Configura los nodos visuales para mostrar la carga
func setup_loading_system():
	loading_wall.visible = false
	loading_circle.pivot_offset = loading_circle.size / 2
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(_rotate_loading_circle, 0.0, 360.0, 1.0)

## Rota el círculo de carga
func _rotate_loading_circle(angle: float):
	if loading_circle:
		loading_circle.rotation_degrees = angle

## Muestra la animación de carga y bloquea entrada
func show_loading():
	if not is_loading:
		is_loading = true
		loading_wall.visible = true
		loading_circle.visible = true
		loading_wall.move_to_front()
		loading_circle.move_to_front()
		await get_tree().process_frame  # Asegura que se actualice visualmente

## Oculta la animación de carga
func hide_loading():
	if is_loading:
		is_loading = false
		loading_wall.visible = false

## Bloquea la entrada cuando se está cargando
func _input(event):
	if is_loading:
		get_viewport().set_input_as_handled()

## Inicia el proceso de login
func login(username: String, password: String):
	if is_loading: return
	current_request_type = RequestType.LOGIN
	show_loading()

	var url = base_url + "/usuarios/login"
	var headers = ["Content-Type: application/json"]
	keep_username = username
	keep_password = password
	var body = JSON.stringify({ "username": username, "password": password })

	timeout_timer.start()
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)

## Inicia el proceso de registro
func register(username: String, password: String, unlocked_characters: Array, unlocked_stages: Array, completed_stages: Array):
	if is_loading: return
	current_request_type = RequestType.REGISTER
	show_loading()

	var url = base_url + "/usuarios/register"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"username": username,
		"password": password,
		"passwordRepeat": password,
		"unlocked_characters": unlocked_characters,
		"unlocked_stages": unlocked_stages,
		"completed_stages": completed_stages
	})

	timeout_timer.start()
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)

## Solicita los datos del juego del usuario actual
func get_game_data():
	if is_loading: return
	current_request_type = RequestType.GET_DATA
	show_loading()

	var url = base_url + "/usuarios/self/gamedata"
	var headers = ["Authorization: Bearer " + auth_token]

	timeout_timer.start()
	http_request.request(url, headers, HTTPClient.METHOD_GET)

## Envía datos del juego para ser guardados
func save_game_data(unlocked_characters: Array[String], unlocked_stages: Array[String], completed_stages: Array[String]):
	if is_loading: return

	# Guarda datos por si es necesario reintentar
	retry_unlocked_characters = unlocked_characters.duplicate()
	retry_unlocked_stages = unlocked_stages.duplicate()
	retry_completed_stages = completed_stages.duplicate()

	current_request_type = RequestType.SAVE_DATA
	show_loading()

	var url = base_url + "/usuarios/self/gamedata"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + auth_token
	]
	var body = JSON.stringify({
		"unlocked_characters": unlocked_characters,
		"unlocked_stages": unlocked_stages,
		"completed_stages": completed_stages
	})

	timeout_timer.start()
	http_request.request(url, headers, HTTPClient.METHOD_PUT, body)

## Devuelve los últimos datos descargados
func get_last_downloaded_data():
	return last_downloaded_data

## Cierra sesión del usuario actual
func log_out():
	keep_username = ""
	keep_password = ""
	auth_token = ""
	last_downloaded_data = null
	pending_retry_request = null
	retry_unlocked_characters.clear()
	retry_unlocked_stages.clear()
	retry_completed_stages.clear()
	hide_loading()

## Llamado cuando una solicitud excede el tiempo de espera
func _on_request_timeout():
	print("Request timed out")
	http_request.cancel_request()
	hide_loading()
	emit_signal("request_timeout")

## Maneja la respuesta del servidor después de una solicitud
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	timeout_timer.stop()
	hide_loading()
	
	var response_text = body.get_string_from_utf8()
	if result != HTTPRequest.RESULT_SUCCESS:
		handle_network_error(result)
		return

	var json = JSON.new()
	var response_data = null
	if response_text != "":
		if json.parse(response_text) == OK:
			response_data = json.data
		else:
			print("Error al parsear JSON")
			return

	match response_code:
		200, 201: handle_success_response(response_data)
		400: handle_bad_request(response_data)
		401: handle_unauthorized(response_data)
		403: handle_forbidden(response_data)
		404: handle_not_found(response_data)
		409: handle_conflict(response_data)
		500: handle_server_error(response_data)
		_: 
			print("Código inesperado: ", response_code)
			if response_data:
				print("Mensaje: ", response_data)

## Maneja respuestas exitosas según el tipo de solicitud
func handle_success_response(data):
	match current_request_type:
		RequestType.LOGIN:
			if data and data.has("token"):
				auth_token = data.token
				if pending_retry_request != null:
					retry_pending_request()
				else:
					emit_signal("login_succesful")
			else:
				print("Falta token en login")

		RequestType.REGISTER:
			emit_signal("register_successful")

		RequestType.GET_DATA:
			last_downloaded_data = data if data else null
			emit_signal("get_game_data_succesful")

		RequestType.SAVE_DATA:
			emit_signal("update_game_data_succesful")

## Maneja errores de red (no conexión, DNS, TLS, etc.)
func handle_network_error(result_code):
	match result_code:
		HTTPRequest.RESULT_CANT_CONNECT: print("No se puede conectar al servidor")
		HTTPRequest.RESULT_CANT_RESOLVE: print("No se puede resolver el host")
		HTTPRequest.RESULT_CONNECTION_ERROR: print("Error de conexión")
		HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR: print("Error TLS")
		HTTPRequest.RESULT_TIMEOUT: print("Tiempo de espera excedido")
		_: print("Error de red desconocido: ", result_code)

## Maneja error 400 (solicitud inválida)
func handle_bad_request(data):
	print("Solicitud inválida (400)")
	if data and data.has("message"):
		print("Mensaje: ", data.message)

## Maneja error 401 (token inválido o login fallido)
func handle_unauthorized(data):
	if current_request_type == RequestType.LOGIN:
		emit_signal("login_unsuccesful")
	else:
		auth_token = ""
		attempt_auto_relogin()

## Maneja error 403 (prohibido)
func handle_forbidden(data):
	print("Acceso denegado (403)")

## Maneja error 404 (no encontrado)
func handle_not_found(data):
	print("Recurso no encontrado (404)")

## Maneja error 409 (conflicto, como nombre de usuario ya registrado)
func handle_conflict(data):
	if current_request_type == RequestType.REGISTER:
		emit_signal("register_username_conflict")
	if data and data.has("message"):
		print("Mensaje: ", data.message)

## Maneja error 500 (error interno del servidor)
func handle_server_error(data):
	print("Error interno del servidor (500)")

## Intenta relogin automático si se tiene usuario y contraseña guardados
func attempt_auto_relogin():
	if keep_username != "" and keep_password != "":
		store_pending_request()
		login(keep_username, keep_password)
	else:
		print("No hay credenciales guardadas para auto-login")

## Guarda la solicitud actual para reintentar tras re-login
func store_pending_request():
	match current_request_type:
		RequestType.GET_DATA:
			pending_retry_request = {"type": "get_data"}
		RequestType.SAVE_DATA:
			pending_retry_request = {"type": "save_data"}
		_:
			pending_retry_request = null

## Reintenta una solicitud guardada tras reautenticación
func retry_pending_request():
	if pending_retry_request == null:
		return
	match pending_retry_request.type:
		"get_data": get_game_data()
		"save_data": save_game_data(retry_unlocked_characters, retry_unlocked_stages, retry_completed_stages)
	pending_retry_request = null
