extends Control

## Referencia al bus de eventos para el login
@onready var event_bus = get_node("%LoginEventBus")
## Referencia al botón para salir del menú
@onready var exit_button = get_node("%ExitButton")
## Contenedor de pestañas que agrupa los formularios
@onready var tab_container = get_node("%TabContainer")
## Referencia al formulario de inicio de sesión
@onready var login_form = get_node("%LoginForm")
## Referencia al formulario de registro
@onready var register_form = get_node("%RegisterForm")
## Panel mostrado al estar logueado
@onready var logged_panel = get_node("%LoggedPanel")
## Gestor de datos en línea, maneja login, registro y token
@onready var online_data_manager = get_node("/root/GameManager/OnlineSaveDataManager")

## Se ejecuta al inicializar el nodo, configurando las pestañas y señales
func _ready() -> void:
	initialize_tabs()

## Inicializa los formularios y conecta las señales de login y registro exitoso
func initialize_tabs() -> void:
	login_form.initialize(online_data_manager)
	register_form.initialize(online_data_manager)
	logged_panel.initialize(online_data_manager)
	
	# Conecta las señales de éxito de login y registro
	online_data_manager.login_succesful.connect(_on_login_succesful)
	online_data_manager.register_successful.connect(_on_register_successful)

## Muestra el menú de login y determina si se debe mostrar el panel logueado
func show_menu() -> void:
	visible = true
	if online_data_manager.auth_token != "":
		show_logged()

## Muestra el formulario de login al presionar el enlace correspondiente
func _on_to_login_link_pressed() -> void:
	show_login()

## Muestra el formulario de registro al presionar el enlace correspondiente
func _on_to_register_link_pressed() -> void:
	show_register()

## Cierra sesión y vuelve a mostrar el login
func _on_log_out_button_pressed() -> void:
	online_data_manager.log_out()
	show_login()

## Oculta el menú actual
func _on_exit_button_pressed() -> void:
	visible = false

## Muestra el formulario de login y oculta los demás
func show_login():
	login_form.visible = true
	register_form.visible = false
	logged_panel.visible = false
	login_form.clear_form()  # Limpia el formulario al mostrar

## Muestra el formulario de registro y oculta los demás
func show_register():
	login_form.visible = false
	register_form.visible = true
	logged_panel.visible = false
	register_form.clear_form()  # Limpia el formulario al mostrar

## Muestra el panel de usuario logueado y oculta los formularios
func show_logged():
	login_form.visible = false
	register_form.visible = false
	logged_panel.visible = true
	logged_panel.update_welcome_message()  # Actualiza el mensaje de bienvenida

## Se ejecuta cuando el login es exitoso, mostrando el panel correspondiente
func _on_login_succesful():
	show_logged()

## Se ejecuta cuando el registro es exitoso, regresando al login
func _on_register_successful():
	show_login()
