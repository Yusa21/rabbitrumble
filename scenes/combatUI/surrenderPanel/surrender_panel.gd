extends PopupPanel

## Referencia al bus de eventos para emitir senales.
var event_bus

## Se ejecuta cuando el nodo entra en la escena.
## Configura el panel como exclusivo para que bloquee otras interacciones.
func _ready() -> void:
	exclusive = true
	pass

## Inicializa el panel con el bus de eventos proporcionado.
## [param bus] Objeto que actua como bus de eventos para comunicacion entre nodos.
func initialize(bus) -> void:
	event_bus = bus

## Muestra el panel de rendicion centrado en la pantalla.
func show_surrender_popup() -> void:
	popup_centered()

## Oculta el panel de rendicion.
func hide_surrender_popup() -> void:
	hide()

## Se ejecuta cuando se presiona el boton de rendirse.
## Reproduce un efecto de sonido y emite la senal de rendicion.
func _on_surrender_button_pressed() -> void:
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	event_bus.emit_signal("giving_up")

## Se ejecuta cuando se presiona el boton de continuar.
## Reproduce un efecto de sonido y oculta el panel de rendicion.
func _on_continue_button_pressed() -> void:
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	hide_surrender_popup()
