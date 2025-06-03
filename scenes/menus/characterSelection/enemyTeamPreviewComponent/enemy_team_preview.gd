extends HBoxContainer

## Referencia al bus de eventos para emitir señales.
var event_bus

## Boton plantilla usado para crear botones de personajes enemigos.
@onready var character_button = get_node("CharacterButton")

## Icono por defecto tomado del boton plantilla.
@onready var default_icon = character_button.texture_normal

## Metodo llamado al iniciar el nodo (no hace nada por ahora).
func _ready() -> void:
	pass

## Inicializa este contenedor con el bus de eventos y la lista de personajes enemigos.
## [param bus] Instancia del CharacterSelectionBus para emitir señales.
## [param char_list] Lista de personajes enemigos a mostrar.
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
		
		# Conecta el boton para emitir la señal al presionarlo
		new_button.pressed.connect(func(): _emit_enemy_character_clicked(character))
	
		# Agrega el boton al contenedor HBox
		add_child(new_button)

## Metodo vacio ya que el manejo esta en las conexiones individuales de los botones.
func _on_character_button_pressed() -> void:
	pass

## Emite la señal de que un personaje enemigo fue clickeado.
## [param character_data] Datos del personaje enemigo seleccionado.
func _emit_enemy_character_clicked(character_data):
	event_bus.emit_signal("enemy_character_clicked", character_data)
