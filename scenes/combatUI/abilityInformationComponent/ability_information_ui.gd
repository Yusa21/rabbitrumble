extends Control
## Interfaz de usuario que muestra la informacion de una habilidad.
## Se encarga de mostrar nombre, multiplicador, tipo de objetivo, descripcion y posiciones de lanzamiento/objetivo.
class_name AbilityInformationUI

@onready var ability_name = get_node("%AbilityNameLabel") ## Nodo para mostrar el nombre de la habilidad.
@onready var circles_container = get_node("%CirclesContainer") ## Contenedor de los circulos de posicion.
@onready var launch_position_ui = get_node("%LaunchPositonUI") ## UI que contiene las posiciones de lanzamiento.
@onready var target_position_ui = get_node("%TargetPositionUI") ## UI que contiene las posiciones objetivo.
@onready var ability_mult_ui = get_node("%MultUI") ## Nodo que muestra el multiplicador de la habilidad.
@onready var ability_targeting = get_node("%TargetingTypeUI") ## Nodo que muestra el tipo de objetivo de la habilidad.
@onready var ability_description = get_node("%AbilityDescriptionLabel") ## Nodo que muestra la descripcion de la habilidad.

const DEFAULT_COLOR = Color("#333333") ## Color por defecto para los circulos.
const ENEMY_TARGET_COLOR = Color("#cf291a") ## Color para objetivos enemigos.
const ALLY_TARGET_COLOR = Color("#2f9049") ## Color para objetivos aliados.
const LAUNCH_POSITION_COLOR = Color("#f09e29") ## Color para posiciones de lanzamiento.

var launch_circles ## Arreglo de nodos de circulos para posiciones de lanzamiento.
var launch_borders ## Arreglo de bordes de circulos para posiciones de lanzamiento.
var target_circles ## Arreglo de nodos de circulos para posiciones objetivo.
var target_borders ## Arreglo de bordes de circulos para posiciones objetivo.

## Funcion de inicializacion de la UI.
func _ready() -> void:
	populate_circle_arrays()

## Llena los arreglos de circulos y bordes con los nodos hijos correspondientes.
func populate_circle_arrays():
	launch_circles = []
	launch_borders = []
	for wrapper in launch_position_ui.get_children():
		var circle = wrapper.get_node("Circle")
		launch_circles.append(circle)
		var border = wrapper.get_node("MarginCircle")
		launch_borders.append(border)
	
	target_circles = []
	target_borders = []
	for wrapper in target_position_ui.get_children():
		var circle = wrapper.get_node("Circle")
		target_circles.append(circle)
		var border = wrapper.get_node("MarginCircle")
		target_borders.append(border)

## Actualiza la interfaz con la informacion de una habilidad.
## [param ability] Datos de la habilidad a mostrar.
## [param is_enemy] Si la habilidad es del enemigo (gira los ciculos de las posiciones).
func update_ability_information_ui(ability: AbilityData, is_enemy = false):

	if is_enemy:
		circles_container.scale.x = -1
		circles_container.position.x = circles_container.size.x 
	else:
		circles_container.scale.x = 1
		circles_container.position.x = 0

	# Agrega revisiones de depuracion para saber cual nodo es nulo
	if ability_name == null:
		print("ability_name node is null!")
	else:
		ability_name.text = str(ability.name)
	   
	if ability_mult_ui == null:
		print("ability_mult_ui node is null!")
	else:
		ability_mult_ui.text = "x" + str(ability.multiplier)

	if ability_targeting == null:
		print("ability_targeting node is null!")
	else:
		ability_targeting.text = get_ability_target_text(ability.target_type)
		
	if ability_description == null:
		print("ability_description node is null!")
	else:
		ability_description.text = ability.description
	
	# Actualiza los circulos despues de configurar los textos de la UI
	update_ability_circles(ability)

## Devuelve un texto legible para el tipo de objetivo de la habilidad.
## [param target_type] Tipo de objetivo como string.
## [return] Texto legible del tipo de objetivo.
func get_ability_target_text(target_type):
	match target_type:
		"multiple_opps":
			return "Multiple opponents"
		"single_opp":
			return "Single opponent"
		"multiple_allies":
			return "Multiple allies"
		"single_ally":
			return "Single ally"
		"self":
			return "Self"
		_:
			return " "

## Actualiza los circulos para reflejar las posiciones de lanzamiento y objetivo de la habilidad.
## [param ability] Datos de la habilidad.
func update_ability_circles(ability: AbilityData):
	reset_circles_to_default()

	var is_self = ability.target_type == "self"
	var is_support = ability.target_type in ["multiple_allies", "single_ally"]
	var target_color = get_target_color(ability.target_type)

	# Posiciones de lanzamiento
	if ability.launch_position != null:
		for i in range(launch_circles.size()):
			var reverse_index = 3 - i # Index al reves para las posiciones
			var circle = launch_circles[i]
			var border = launch_borders[i]
			var position = reverse_index + 1  # Convierte el index a una posicion

			var is_launch_position = position in ability.launch_position
			var is_target_position = position in ability.target_position

			if is_self and is_launch_position:
				border.modulate = LAUNCH_POSITION_COLOR
			else:
				# Regla 1: Color del centro
				if is_launch_position:
					circle.modulate = LAUNCH_POSITION_COLOR
				else:
					circle.modulate = DEFAULT_COLOR

				# Regla 2: Color del borde
				if is_support and is_target_position:
					border.modulate = ALLY_TARGET_COLOR
				else:
					# Hacer que coincida con el centro (para que parezca solido o por defecto)
					border.modulate = circle.modulate

	# Posiciones objetivo (solo si no es soporte ni es a uno mismo)
	if not is_support and not is_self and ability.target_position != null:
		for i in range(target_circles.size()):
			var circle = target_circles[i]
			var border = target_borders[i]
			var position = i + 1  # Desde 1

			if position in ability.target_position:
				circle.modulate = target_color
				border.modulate = target_color

## Devuelve el color correspondiente segun el tipo de objetivo.
## [param target_type] Tipo de objetivo como string.
## [return] Color asociado al tipo de objetivo.
func get_target_color(target_type: String) -> Color:
	match target_type:
		"multiple_opps", "single_opp":
			return ENEMY_TARGET_COLOR
		"multiple_allies", "single_ally", "self":
			return ALLY_TARGET_COLOR
		_:
			return DEFAULT_COLOR

## Restaura todos los circulos y bordes a su color por defecto.
func reset_circles_to_default():
	# Reinicia los visuales de lanzamiento
	if launch_circles and launch_borders:
		for i in launch_circles.size():
			var circle = launch_circles[i]
			var border = launch_borders[i]
			circle.modulate = DEFAULT_COLOR
			border.modulate = DEFAULT_COLOR

	# Reinicia los visuales de objetivo
	if target_circles and target_borders:
		for i in target_circles.size():
			var circle = target_circles[i]
			var border = target_borders[i]
			circle.modulate = DEFAULT_COLOR
			border.modulate = DEFAULT_COLOR
