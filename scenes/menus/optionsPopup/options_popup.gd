extends PopupPanel
class_name OptionsMenuPopup

@onready var master_volume_slider = get_node("%MasterVolumeSlider")
@onready var music_volume_slider = get_node("%MusicVolumeSlider")
@onready var sfx_volume_slider = get_node("%SFXVolumeSlider")

# Referencia al singleton GameManager
var game_manager: GameManager

## Método llamado al iniciar el nodo.
func _ready() -> void:
	# Obtener referencia al GameManager
	game_manager = get_node("/root/GameManager")
	
	# Conectar sliders a sus respectivos manejadores de señal
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	sfx_volume_slider.drag_ended.connect(_on_sfx_drag_ended)
	
	# Conectar señal que se emite justo antes de que el popup aparezca
	about_to_popup.connect(_update_slider_values)
	
	# Mantiene el popup activo y exclusivo (no se cierra al hacer clic dentro)
	exclusive = true

## Muestra el popup de opciones centrado en pantalla.
func show_options_pop_up():
	_update_slider_values()
	popup_centered()

## Cierra explícitamente el popup de opciones.
func close_options_popup():
	hide()

## Actualiza los valores de los sliders basándose en la configuración actual.
func _update_slider_values() -> void:
	master_volume_slider.value = game_manager.get_master_volume_percent()
	music_volume_slider.value = game_manager.get_music_volume_percent()
	sfx_volume_slider.value = game_manager.get_sfx_volume_percent()

## [param value] El nuevo valor del volumen maestro (0.0 a 100.0)
func _on_master_volume_changed(value: float) -> void:
	game_manager.set_master_volume_percent(value)
	get_viewport().set_input_as_handled()  # Previene propagación de eventos

## [param value] El nuevo valor del volumen de música (0.0 a 100.0)
func _on_music_volume_changed(value: float) -> void:
	game_manager.set_music_volume_percent(value)
	get_viewport().set_input_as_handled()

## [param value] El nuevo valor del volumen de efectos de sonido (0.0 a 100.0)
func _on_sfx_volume_changed(value: float) -> void:
	game_manager.set_sfx_volume_percent(value)
	get_viewport().set_input_as_handled()

## [param _value] Valor final del slider de SFX tras soltar el drag.
func _on_sfx_drag_ended(_value) -> void:
	GameManager.play_sfx("res://audio/soundEffects/buzzer.ogg")

## Manejador del botón de "Hecho" para cerrar el popup.
func _on_done_button_pressed() -> void:
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	close_options_popup()
