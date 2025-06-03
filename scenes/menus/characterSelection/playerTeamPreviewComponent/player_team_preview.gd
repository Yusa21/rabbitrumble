extends HBoxContainer

## Referencia al bus de eventos para emitir señales.
var event_bus

## Boton plantilla usado para crear botones de personajes.
@onready var character_button = get_node("CharacterButton")

## Icono por defecto tomado del boton plantilla.
@onready var default_icon = character_button.texture_normal

## Lista de personajes actualmente seleccionados (almacena datos completos).
var selected_characters = []

## Maximo numero de personajes permitidos en la seleccion.
const MAX_CHARACTERS = 4

## Metodo llamado al iniciar el nodo.
## Oculta el boton plantilla para que no se muestre directamente.
func _ready() -> void:
	if character_button:
		character_button.visible = false

## Inicializa este contenedor con el bus de eventos recibido y conecta señales.
## [param bus] Instancia del CharacterSelectionBus para emitir y recibir señales.
func initialize(bus):
	event_bus = bus
	event_bus.character_right_clicked.connect(_on_character_right_clicked)
	event_bus.clear_button_clicked.connect(_on_clear_button_clicked)

## Maneja el click derecho en un personaje para agregar o remover de la seleccion.
## [param char_data] Datos del personaje clickeado.
func _on_character_right_clicked(char_data):
	var char_id = char_data.character_id
	
	# Busca si el personaje ya esta seleccionado
	var existing_index = -1
	for i in range(selected_characters.size()):
		if selected_characters[i].character_id == char_id:
			existing_index = i
			break
	
	# Si ya esta seleccionado, lo remueve
	if existing_index != -1:
		_remove_character(char_data)
		return
	
	# Si no esta seleccionado pero ya se alcanzo el maximo, ignora
	if selected_characters.size() >= MAX_CHARACTERS:
		return
	
	# Agrega el personaje a la seleccion
	selected_characters.append(char_data)
	event_bus.emit_signal("character_added_to_team", char_id)
	add_character_button(char_data)

## Maneja la señal de limpiar seleccion para remover todos los personajes.
func _on_clear_button_clicked():
	clear_selection()

## Agrega un boton para representar al personaje en la UI.
## [param char_data] Datos del personaje a mostrar.
func add_character_button(char_data):
	if !character_button:
		push_error("Character button template not found!")
		return
	
	var new_button = character_button.duplicate()
	new_button.visible = true

	GameManager.play_sfx("res://audio/soundEffects/seedlift.ogg")
	
	# Usa el icono del personaje o el icono por defecto si no hay.
	if char_data.character_icon != null:
		new_button.texture_normal = char_data.character_icon
	else:
		new_button.texture_normal = default_icon
	
	# Guarda los datos del personaje en el boton para referencias futuras.
	new_button.set_meta("character_data", char_data)
	
	# Conecta la entrada GUI para detectar clicks derechos y doble click izquierdo y remover personaje.
	new_button.gui_input.connect(func(event):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				_remove_character(char_data)
			elif event.button_index == MOUSE_BUTTON_LEFT and event.doubleclick:
				_remove_character(char_data)
	)
	
	# Conecta el click izquierdo para emitir la señal de personaje seleccionado.
	new_button.pressed.connect(func(): _emit_character_clicked(char_data))
	
	# Agrega el boton a este contenedor HBoxContainer.
	add_child(new_button)

## Remueve un personaje de la seleccion y actualiza la UI.
## [param char_data] Datos del personaje a remover.
func _remove_character(char_data):
	var char_id = char_data.character_id
	
	GameManager.play_sfx("res://audio/soundEffects/seedlift.ogg")

	# Elimina el personaje de la lista de seleccionados.
	for i in range(selected_characters.size()):
		if selected_characters[i].character_id == char_id:
			selected_characters.remove_at(i)
			break
	
	# Busca y elimina el boton asociado en la UI.
	for child in get_children():
		if child != character_button and child.has_meta("character_data"):
			var btn_char_data = child.get_meta("character_data")
			if btn_char_data.character_id == char_id:
				child.queue_free()
				break

	# Emite la señal de personaje removido.
	event_bus.emit_signal("character_removed_from_team", char_id)

## Emite la señal de que un personaje fue seleccionado.
## [param char_data] Datos del personaje seleccionado.
func _emit_character_clicked(char_data):
	event_bus.emit_signal("character_clicked", char_data)

## Limpia toda la seleccion removiendo personajes y botones.
func clear_selection():
	GameManager.play_sfx("res://audio/soundEffects/buzzer.ogg")

	# Emite señales para todos los personajes removidos.
	for char_data in selected_characters:
		event_bus.emit_signal("character_removed_from_team", char_data.character_id)
	
	selected_characters.clear()
	
	# Elimina todos los botones excepto el boton plantilla.
	for child in get_children():
		if child != character_button:
			child.queue_free()
