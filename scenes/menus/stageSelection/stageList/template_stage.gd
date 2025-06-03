## Contenedor para mostrar informacion de una etapa individual en la interfaz de seleccion.
## Este componente maneja la visualizacion de datos de etapa y detecta clics del usuario.
extends HBoxContainer

## Referencia al nodo que muestra el numero de la etapa.
var stage_number_display

## Referencia al nodo que muestra el nombre de la etapa.
var stage_name_display

## Referencia al nodo que muestra el indicador de completado.
var completed_check_display

## Referencia al nodo que muestra la dificultad de la etapa.
var stage_difficulty_display

## Datos completos de la etapa para referencia cuando se hace clic.
var stage_data

## Inicializa el control para procesar entrada de mouse.
## Se asegura de que el filtro de mouse este configurado para capturar eventos.
func _init():
	mouse_filter = Control.MOUSE_FILTER_STOP

## Configura las referencias a los nodos hijos despues de la duplicacion.
## Busca y almacena referencias a todos los nodos de visualizacion necesarios.
func _ready() -> void:
	# Buscar nodos hijos despues de la duplicacion
	stage_number_display = get_node_or_null("StageNumber")
	stage_name_display = get_node_or_null("StageName")
	completed_check_display = get_node_or_null("CompletedCheck")
	stage_difficulty_display = get_node_or_null("StageDifficulty")
	
	# Informacion de depuracion
	if stage_number_display == null:
		print("Warning: StageNumber node not found in ", get_path())

## Inicializa el componente con los datos de la etapa especificada.
## Configura todos los elementos de visualizacion con la informacion proporcionada.
## [param stage_number] El numero identificador de la etapa.
## [param stage_name] El nombre descriptivo de la etapa.
## [param stage_difficulty] El nivel de dificultad de la etapa.
## [param completed] Estado booleano que indica si la etapa fue completada.
## [param stage_data_ref] Referencia opcional a los datos completos de la etapa.
func initialize(stage_number, stage_name, stage_difficulty, completed, stage_data_ref=null):
	# Almacenar los datos de la etapa para referencia cuando se haga clic
	stage_data = stage_data_ref
	
	# Asegurarse de que todas las referencias de nodos sean validas antes de acceder a ellas
	if stage_number_display:
		stage_number_display.text = str(stage_number)  # Convertir a string para mayor seguridad
	else:
		print("Error: stage_number_display is null")
		
	if stage_name_display:
		stage_name_display.text = stage_name
	
	if stage_difficulty_display:
		stage_difficulty_display.text = str(stage_difficulty)
   
	# Mostrar u ocultar el indicador de completado si existe
	if completed_check_display:
		completed_check_display.visible = completed
	else:
		print("Error: completed_check_display is null")

## Maneja la entrada de la interfaz grafica para detectar clics del mouse.
## Sobrescribe el metodo base para procesar clics directamente en este componente.
## [param event] El evento de entrada recibido del sistema de input.
func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Stage clicked directly: ", stage_data)
		# El padre manejara la senal a traves del _on_stage_selected conectado