extends HBoxContainer

## Referencia al bus de eventos para emitir señales
var event_bus

## Referencia al boton plantilla para las habilidades
@onready var ability_button = get_node("AbilityButton")
@onready var default_icon = ability_button.texture_normal

func _ready() -> void:
	pass

## Inicializa el nodo con el bus de eventos y conecta la señal de personaje seleccionado
## [param bus] Instancia del CharacterSelectionBus para recibir señales
func initialize(bus):
	event_bus = bus
	event_bus.character_clicked.connect(_on_character_clicked)

## Se conecta dinamicamente a cada boton de habilidad para emitir la señal al presionar
func _on_ability_button_pressed() -> void:
	# Este metodo es placeholder, la conexion se hace con lambdas en setup_ability_button
	pass

## Cuando se selecciona un personaje, carga todas sus habilidades en la barra de botones
## [param char_data] Datos del personaje seleccionado con su lista de habilidades
func _on_character_clicked(char_data):
	# Limpia los botones existentes excepto el primero (plantilla)
	for child in get_children():
		if child != ability_button:
			child.queue_free()
	
	# Si el personaje no tiene habilidades, oculta el boton plantilla y retorna
	if not char_data.abilities or char_data.abilities.size() == 0:
		ability_button.visible = false
		return
	
	# Configura el primer boton con la primera habilidad y lo hace visible
	var first_ability = char_data.abilities[0]
	setup_ability_button(ability_button, first_ability)
	ability_button.visible = true
	
	# Crea botones duplicados para las habilidades restantes y los añade al contenedor
	for i in range(1, char_data.abilities.size()):
		var ability_data = char_data.abilities[i]
		var new_button = ability_button.duplicate()
		setup_ability_button(new_button, ability_data)
		add_child(new_button)

## Configura un boton con la informacion de una habilidad especifica
## [param button] Nodo boton a configurar
## [param ability_data] Datos de la habilidad a mostrar
func setup_ability_button(button, ability_data):
	# Asigna la textura si existe, sino pone el icono por defecto
	if ability_data.icon_sprite:
		button.texture_normal = ability_data.icon_sprite
		button.texture_pressed = ability_data.icon_pressed
	else:
		button.texture_normal = default_icon
	
	# Guarda los datos de la habilidad en el boton para referencia
	button.set_meta("ability_data", ability_data)
	
	# Se asegura de desconectar la señal si ya esta conectada para evitar multiples conexiones
	if button.is_connected("pressed", _on_ability_button_pressed):
		button.disconnect("pressed", _on_ability_button_pressed)
	
	# Conecta la señal pressed con una funcion lambda que emite la habilidad clickeada
	button.pressed.connect(func(): _emit_ability_clicked(ability_data))
	
## Emite la señal ability_clicked con la habilidad seleccionada en el bus de eventos
## [param ability_data] Datos de la habilidad que fue clickeada
func _emit_ability_clicked(ability_data):
	event_bus.emit_signal("ability_clicked", ability_data)
