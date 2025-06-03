extends VBoxContainer

## Bus de eventos para emitir señales del menú principal.
var event_bus

func _ready() -> void:
	pass

## Inicializa este componente con una referencia al bus de eventos.
## 
## [param bus] El bus de eventos con las señales del menú principal.
func initialize(bus):
	event_bus = bus

## Llamado cuando se presiona el botón de "Start".
## Emite la señal `start_button_clicked` a través del bus.
func _on_start_button_pressed() -> void:
	event_bus.emit_signal("start_button_clicked")

## Llamado cuando se presiona el botón de "Exit".
## Emite la señal `exit_button_clicked` a través del bus.
func _on_exit_button_pressed() -> void:
	event_bus.emit_signal("exit_button_clicked")
