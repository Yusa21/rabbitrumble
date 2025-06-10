extends VBoxContainer
class_name LoginForm

## Campo de entrada para el nombre de usuario
@onready var username_input = get_node("%UsernameInputLogin")
## Etiqueta para mostrar errores relacionados con el nombre de usuario
@onready var username_error = get_node("%UsernameErrorLogin")
## Campo de entrada para la contraseña
@onready var password_input = get_node("%PasswordInputLogin")
## Etiqueta para mostrar errores relacionados con la contraseña
@onready var password_error = get_node("%PasswordErrorLogin")

## Referencia al gestor de datos en línea
var save_game_data_manager

## Inicializa el formulario de login y conecta las señales del gestor de datos
## [param save_manager] Instancia del OnlineSaveDataManager
func initialize(save_manager):
	save_game_data_manager = save_manager
	save_game_data_manager.login_unsuccesful.connect(_on_login_unsuccesful)
	save_game_data_manager.request_timeout.connect(_on_request_timeout)

## Se ejecuta al presionar el botón de login. Valida los campos y envía los datos.
func _on_login_button_pressed() -> void:
	clear_errors()
	
	var username = username_input.text.strip_edges()
	var password = password_input.text
	
	# Validación básica
	if username.is_empty():
		username_error.text = "Username is required"
		return
	
	if password.is_empty():
		password_error.text = "Password is required"
		return
	
	save_game_data_manager.login(username, password)

## Se ejecuta cuando el login falla por credenciales incorrectas
func _on_login_unsuccesful():
	password_error.text = "The username or password is wrong"

## Se ejecuta cuando la solicitud excede el tiempo de espera
func _on_request_timeout():
	password_error.text = "Connection timeout. Please try again."

## Limpia todos los mensajes de error del formulario
func clear_errors():
	username_error.text = ""
	password_error.text = ""

## Limpia todos los campos de entrada y errores del formulario
func clear_form():
	username_input.text = ""
	password_input.text = ""
	clear_errors()