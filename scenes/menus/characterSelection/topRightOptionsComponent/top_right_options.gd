extends HBoxContainer

## Referencia al bus de eventos para emitir senales.
var event_bus

## Inicializacion del nodo (no hace nada por ahora).
func _ready() -> void:
	pass

## Inicializa este contenedor con el bus de eventos recibido.
## [param bus] Instancia del CharacterSelectionBus para emitir senales.
func initialize(bus):
	event_bus = bus

## Metodo llamado cuando se presiona el boton de regresar.
## Emite la senal correspondiente a traves del bus de eventos.
func _on_back_button_pressed() -> void:
	event_bus.emit_signal("back_button_clicked")
