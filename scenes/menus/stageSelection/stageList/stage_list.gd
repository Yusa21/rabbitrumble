## Contenedor que maneja la lista de etapas disponibles en la interfaz de seleccion.
## Se encarga de crear y mostrar dinamicamente las entradas de etapas desbloqueadas.
extends VBoxContainer

## Referencia al bus de eventos para comunicacion entre componentes.
var event_bus

## Plantilla de entrada de etapa que se usa para duplicar nuevas entradas.
## Se obtiene usando el identificador unico de nodo.
@onready var template_stage_entry = get_node("%TemplateStage")

## Inicializa el componente ocultando la plantilla de etapa.
## La plantilla no debe ser visible ya que solo se usa como modelo para duplicacion.
func _ready() -> void:
    # Ocultar la plantilla ya que no queremos que sea visible
    if template_stage_entry:
        template_stage_entry.visible = false

## Configura el componente con el bus de eventos y muestra las etapas desbloqueadas.
## [param bus] El bus de eventos para comunicacion entre componentes.
## [param unlocked_stages] Array de etapas que estan desbloqueadas para el jugador.
## [param completed_stages] Array de etapas que ya han sido completadas.
func initialize(bus, unlocked_stages, completed_stages):
    event_bus = bus
    show_all_unlocked_stages(unlocked_stages, completed_stages)

## Muestra todas las etapas desbloqueadas creando entradas dinamicas.
## Limpia las entradas existentes y crea nuevas basadas en los datos proporcionados.
## [param unlocked] Array de datos de etapas desbloqueadas.
## [param completed] Array de IDs de etapas completadas.
func show_all_unlocked_stages(unlocked, completed):
    # Limpiar entradas existentes primero (excepto la plantilla)
    for child in get_children():
        if child != template_stage_entry and child.visible:
            child.queue_free()
   
    # Crear una nueva instancia para cada etapa desbloqueada
    for stage in unlocked:
        var stage_entry = template_stage_entry.duplicate()
        stage_entry.visible = true
       
        # Importante: Agregar el hijo al arbol de escena antes de llamar _ready
        add_child(stage_entry)
       
        # Permitir que el nodo inicialice sus referencias de hijos
        await get_tree().process_frame
       
        # Verificar si el ID de esta etapa esta en la lista de completadas
        var is_completed = completed.has(stage.id)
       
        # Inicializar la entrada de etapa con los datos
        stage_entry.initialize(
            str(stage.number),  # Convertir a string en caso de que sea un numero
            stage.name,
            stage.difficulty,
            is_completed,
            stage  # Pasar todos los datos de la etapa
        )
       
        # Conectar senal para cuando se seleccione la etapa
        stage_entry.connect("gui_input", _on_stage_selected.bind(stage))

## Maneja la seleccion de una etapa cuando el usuario hace clic.
## Detecta clics del mouse y emite una senal a traves del bus de eventos.
## [param event] El evento de entrada del mouse.
## [param stage] Los datos completos de la etapa seleccionada.
func _on_stage_selected(event, stage):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if event_bus:
            # Emitir una senal a traves del bus de eventos cuando se selecciona una etapa
            event_bus.emit_signal("stage_clicked", stage)