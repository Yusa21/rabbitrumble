extends HBoxContainer

## Componente de vista previa del equipo enemigo que muestra los iconos
## de los personajes enemigos de una etapa seleccionada en una fila horizontal.

## Bus de eventos para la comunicacion entre componentes.
var event_bus

## Icono plantilla usado como base para crear nuevos iconos de enemigos.
@onready var template_icon = get_node("%TemplateEnemyIcon")

## Textura por defecto para enemigos que no tienen icono personalizado.
@onready var default_icon = template_icon.texture

func _ready() -> void:
    pass

## Inicializa el componente con el bus de eventos proporcionado.
## Configura las conexiones de senales y prepara el icono plantilla.
## [param bus] El bus de eventos del sistema.
func initialize(bus):
    event_bus = bus
    event_bus.stage_clicked.connect(_on_stage_clicked)
    if !template_icon:
        push_error("Template button not found")
   
    template_icon.visible = false

## Maneja el evento cuando se selecciona una etapa.
## Actualiza la vista previa con los enemigos de la etapa.
## [param stage] Los datos de la etapa seleccionada.
func _on_stage_clicked(stage):
    update_enemy_preview(stage)

## Actualiza la vista previa del equipo enemigo.
## Elimina los iconos anteriores y crea nuevos iconos para cada enemigo.
## [param stage] Los datos de la etapa que contiene la lista de enemigos.
func update_enemy_preview(stage):
    var char_list = get_char_list(stage)
    
    # Eliminar iconos anteriores excepto la plantilla
    for child in get_children():
        if child != template_icon:
            child.queue_free()
    
    # Crear nuevo icono para cada personaje enemigo
    for character in char_list:
        var new_icon = template_icon.duplicate()
        new_icon.visible = true
        if character.character_icon != null:
            new_icon.texture = character.character_icon
        else:
            new_icon.texture = default_icon
        add_child(new_icon)

## Obtiene la lista de personajes enemigos de una etapa.
## Carga los datos de cada enemigo desde el repositorio de personajes.
## [param stage] Los datos de la etapa.
## [return] Array con los datos de los personajes enemigos.
func get_char_list(stage):
    var char_list: Array
    for char_id in stage.enemies:
        var new_enemy = CharacterRepo.load_character_data_by_id(char_id)
        if new_enemy != null:
            char_list.append(new_enemy)
        else:
            push_error("Enemy with id: " + str(char_id) + "not found")
    return char_list