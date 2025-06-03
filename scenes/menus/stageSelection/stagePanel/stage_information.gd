extends VBoxContainer
class_name StageInformationPanel

## Panel de informacion de etapa que muestra detalles de la etapa seleccionada.
## Maneja la visualizacion del nombre, dificultad, descripcion y estado de completado
## de una etapa del juego, asi como la vista previa del equipo enemigo.

## Bus de eventos para la comunicacion entre componentes.
var event_bus

## Referencia al nodo que muestra el nombre de la etapa.
@onready var name_display = get_node("%StageName")

## Referencia al nodo que muestra la dificultad de la etapa.
@onready var difficulty_display = get_node("%StageDifficulty")

## Referencia al componente de vista previa del equipo enemigo.
@onready var enemy_team_preview = get_node("%EnemyTeamPreview")

## Referencia al nodo que muestra la descripcion de la etapa.
@onready var description_display = get_node("%StageDescription")

## Referencia al nodo que indica si la etapa fue completada.
@onready var completed_check = get_node("%CompletedCheck")

func _ready() -> void:
	pass

## Inicializa el panel con el bus de eventos proporcionado.
## Configura las conexiones de senales necesarias.
## [param bus] El bus de eventos del sistema.
func initialize(bus):
	event_bus = bus

	enemy_team_preview.initialize(bus)
	event_bus.stage_clicked.connect(_on_stage_clicked)

## Maneja el evento cuando se hace clic en una etapa.
## Actualiza la informacion mostrada en el panel.
## [param stage] Los datos de la etapa seleccionada.
func _on_stage_clicked(stage: StageData):
	_update_stage_information(stage)

## Maneja el evento cuando se presiona el boton de inicio.
## Emite la senal correspondiente a traves del bus de eventos.
func _on_start_button_pressed() -> void:
	event_bus.emit_signal("start_button_clicked")

## Actualiza toda la informacion de la etapa en la interfaz.
## Configura el nombre, dificultad, descripcion y estado de completado.
## [param stage] Los datos de la etapa a mostrar.
func _update_stage_information(stage: StageData):
	name_display.text = str(stage.name)
	difficulty_display.text = str(stage.difficulty)
	description_display.text = str(stage.description)
	if stage.id in GameManager.completed_stage_list:
		completed_check.visible = true
	else:
		completed_check.visible = false