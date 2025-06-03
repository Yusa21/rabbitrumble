extends GridContainer

## Referencia al bus de eventos para emitir señales.
var event_bus

## Boton plantilla usado para crear botones de personajes.
@onready var character_button = get_node("CharacterButton")

## Icono por defecto tomado del boton plantilla.
@onready var default_icon = character_button.texture_normal

## Metodo llamado al iniciar el nodo (no hace nada por ahora).
func _ready() -> void:
	pass

## Inicializa este contenedor con el bus de eventos y la lista de personajes.
## [param bus] Instancia del CharacterSelectionBus para emitir señales.
## [param char_list] Lista de personajes a mostrar en el grid.
func initialize(bus, char_list):
	event_bus = bus
	
	# Verifica que el boton plantilla exista
	if !character_button:
		push_error("Character button template not found!")
		return
	
	# Oculta el boton plantilla para que no sea visible
	character_button.visible = false
	
	# Elimina cualquier boton existente excepto el boton plantilla
	for child in get_children():
		if child != character_button:
			child.queue_free()
	
	# Crea un boton para cada personaje en la lista
	for character in char_list:
		var new_button = character_button.duplicate()
		new_button.visible = true
		
		# Usa el icono del personaje o el icono por defecto si no hay
		if character.character_icon != null:
			new_button.texture_normal = character.character_icon
		else:
			new_button.texture_normal = default_icon
		
		# Guarda los datos del personaje en el boton para referencias futuras
		new_button.set_meta("character_data", character)
		
		# Conecta la señal pressed para emitir click izquierdo
		new_button.pressed.connect(func(): _emit_character_clicked(character))
		
		# Conecta la entrada gui para detectar clicks derechos y doble click izquierdo
		new_button.gui_input.connect(func(event): _on_button_gui_input(event, character))

		# Conecta las señales para cambiar el estado de escala de grises cuando se agrega o remueve un personaje del equipo
		bus.character_added_to_team.connect(func(char_id): set_character_grayscale(char_id, true))
		bus.character_removed_from_team.connect(func(char_id): set_character_grayscale(char_id, false))

		# Agrega el boton al contenedor Grid
		add_child(new_button)

## Metodo vacio ya que el manejo esta en las conexiones individuales de los botones.
func _on_character_button_pressed() -> void:
	pass

## Maneja eventos de entrada GUI para detectar clicks derechos y doble click izquierdo.
## [param event] Evento de entrada.
## [param character_data] Datos del personaje asociado al boton.
func _on_button_gui_input(event, character_data):
	# Click derecho
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_emit_character_right_clicked(character_data)

	# Doble click izquierdo
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		_emit_character_right_clicked(character_data)

## Emite la señal de personaje clickeado (click izquierdo).
## [param character_data] Datos del personaje seleccionado.
func _emit_character_clicked(character_data):
	event_bus.emit_signal("character_clicked", character_data)

## Emite la señal de personaje clickeado con click derecho o doble click izquierdo.
## [param character_data] Datos del personaje seleccionado.
func _emit_character_right_clicked(character_data):
	event_bus.emit_signal("character_right_clicked", character_data)

## Cambia la tonalidad del boton para mostrarlo en escala de grises o normal.
## [param character_id] ID del personaje para modificar.
## [param grayscale] Si es true aplica escala de grises, si es false vuelve a color normal.
func set_character_grayscale(character_id: String, grayscale: bool) -> void:
	for child in get_children():
		if child == character_button:
			continue
		if child.has_meta("character_data"):
			var data = child.get_meta("character_data")
			if data.character_id == character_id:
				if grayscale:
					child.modulate = Color(0.5, 0.5, 0.5)  # Escala de grises
				else:
					child.modulate = Color(1, 1, 1)  # Color normal
				break
