extends VBoxContainer
class_name RegisterForm

## Campo de entrada para el nombre de usuario
@onready var username_input = get_node("%UsernameInput")
## Etiqueta para mostrar errores relacionados al nombre de usuario
@onready var username_error = get_node("%UsernameError")
## Campo de entrada para la contraseña
@onready var password_input = get_node("%PasswordInput")
## Etiqueta para mostrar errores relacionados a la contraseña
@onready var password_error = get_node("%PasswordError")
## Campo de entrada para repetir la contraseña
@onready var password_repeat_input = get_node("%PasswordRepeatInput")
## Etiqueta para mostrar errores relacionados a la repetición de contraseña
@onready var password_repeat_error = get_node("%PasswordRepeatError")

## Referencia al gestor de datos para manejar el registro en línea
var save_game_data_manager

## Inicializa el formulario y conecta las señales del gestor de datos
## [param save_manager] Instancia del OnlineSaveDataManager para registrar usuarios
func initialize(save_manager):
	save_game_data_manager = save_manager
	save_game_data_manager.register_successful.connect(_on_register_successful)
	save_game_data_manager.register_username_conflict.connect(_on_register_username_conflict)
	save_game_data_manager.request_timeout.connect(_on_request_timeout)

## Se ejecuta al presionar el botón de registro, validando campos y enviando los datos
func _on_register_button_pressed() -> void:
	clear_errors()
	
	var username = username_input.text.strip_edges()
	var password = password_input.text
	var password_repeat = password_repeat_input.text
	
	# Validación de los campos
	var is_valid = true
	
	if username.is_empty():
		username_error.text = "Username is required"
		is_valid = false
	elif username.length() < 3:
		username_error.text = "Username must be at least 3 characters"
		is_valid = false
	
	if password.is_empty():
		password_error.text = "Password is required"
		is_valid = false
	elif not is_password_valid(password):
		password_error.text = "Password must be at least 8 characters with letters and numbers"
		is_valid = false
	
	if password_repeat.is_empty():
		password_repeat_error.text = "Please repeat your password"
		is_valid = false
	elif password != password_repeat:
		password_repeat_error.text = "Passwords don't match"
		is_valid = false
	
	if not is_valid:
		return
	
	# Llama al método de registro con los datos por defecto del juego
	var default_unlocked_characters = GameManager.unlocked_char_list
	var default_unlocked_stages = GameManager.unlocked_stage_list
	var default_completed_stages = GameManager.completed_stage_list
	
	save_game_data_manager.register(
		username, 
		password, 
		default_unlocked_characters, 
		default_unlocked_stages, 
		default_completed_stages
	)

## Se ejecuta cuando el registro es exitoso, limpiando el formulario
func _on_register_successful():
	clear_form()
	print("Registration successful! You can now login.")

## Se ejecuta si el nombre de usuario ya está en uso
func _on_register_username_conflict():
	username_error.text = "Username already exists"

## Se ejecuta cuando hay un error de conexión o timeout
func _on_request_timeout():
	password_repeat_error.text = "Connection timeout. Please try again."

## Valida que la contraseña tenga al menos 8 caracteres, con letras y números
## [param password] La contraseña a validar
## [return] true si la contraseña es válida, false si no
func is_password_valid(password: String) -> bool:
	# Regex: ^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$
	# Al menos 8 caracteres, contiene al menos una letra y un número
	var regex = RegEx.new()
	regex.compile("^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$")
	return regex.search(password) != null

## Limpia los mensajes de error del formulario
func clear_errors():
	username_error.text = ""
	password_error.text = ""
	password_repeat_error.text = ""

## Limpia todos los campos y errores del formulario
func clear_form():
	username_input.text = ""
	password_input.text = ""
	password_repeat_input.text = ""
	clear_errors()
