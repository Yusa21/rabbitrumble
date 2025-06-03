## Contenedor horizontal que maneja la navegacion de la interfaz.
## Este componente se encarga del boton de regreso en la UI.
extends HBoxContainer

## Referencia al bus de eventos para comunicacion entre componentes.
var event_bus

func _ready() -> void:
	pass

## Configura el bus de eventos para este componente.
## [param bus] El objeto event bus que manejara los eventos.
func initialize(bus):
	event_bus = bus

## Emite una senal a traves del event bus para notificar
## que se ha presionado el boton de regreso.
func _on_back_button_pressed() -> void:
	event_bus.emit_signal("back_button_clicked")