extends VBoxContainer

## Referencia al bus de eventos para recibir señales.
var event_bus

## Lista de habilidades del personaje actualmente mostrado.
var ability_list

## Referencias a los nodos de UI para mostrar informacion del personaje
@onready var char_name_display = get_node("%CharName")
@onready var hp_display = get_node("%HPValue")
@onready var atk_display = get_node("%AtkValue")
@onready var def_display = get_node("%DefValue")
@onready var speed_display = get_node("%SpeedValue")
@onready var char_image_display = get_node("%CharacterImage")
@onready var char_description_display = get_node("%CharDescription")
@onready var ability_list_display = get_node("%AbilityList")
@onready var ability_information_display = get_node("%AbilityInformationUI")

## Indica si el personaje actual es enemigo o no.
var current_character_is_enemy = false

## Metodo llamado al iniciar el nodo (no hace nada por ahora).
func _ready() -> void:
	pass

## Inicializa el panel con el bus de eventos y conecta las señales necesarias.
## [param bus] Instancia del CharacterSelectionBus para recibir señales.
func initialize(bus):
	event_bus = bus
	event_bus.character_clicked.connect(_on_character_clicked)
	event_bus.ability_clicked.connect(_on_ability_clicked)
	event_bus.enemy_character_clicked.connect(_on_enemy_character_clicked)

	# Inicializa la lista de habilidades con el bus para que tambien pueda emitir eventos
	ability_list_display.initialize(event_bus)

## Maneja cuando se selecciona un personaje enemigo.
## Actualiza la informacion del panel y marca que el personaje es enemigo.
func _on_enemy_character_clicked(char_data):
	current_character_is_enemy = true
	_update_character_information(char_data)

## Maneja cuando se selecciona un personaje jugador.
## Actualiza la informacion del panel y marca que el personaje no es enemigo.
func _on_character_clicked(char_data):
	current_character_is_enemy = false
	_update_character_information(char_data)
	
## Actualiza todos los campos del panel con la informacion del personaje recibido.
## [param char_data] Datos del personaje seleccionado.
func _update_character_information(char_data):
	# Actualiza texto y valores visibles
	char_name_display.text = str(char_data.character_name)
	hp_display.text = str(char_data.max_hp)
	atk_display.text = str(char_data.attack)
	def_display.text = str(char_data.defense)
	speed_display.text = str(char_data.speed)
	char_description_display.text = str(char_data.character_description)
	char_image_display.texture = char_data.idle_sprite

	# Guarda la lista de habilidades del personaje y muestra la primera habilidad en el panel de informacion
	ability_list = char_data.abilities
	ability_information_display.update_ability_information_ui(ability_list[0], current_character_is_enemy)

## Maneja cuando se selecciona una habilidad para mostrar su informacion.
## [param ability_data] Datos de la habilidad seleccionada.
func _on_ability_clicked(ability_data):
	ability_information_display.update_ability_information_ui(ability_data)
