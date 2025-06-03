## Popup que muestra informacion cuando se desbloquea un nuevo personaje.
## Extiende PopupPanel para mostrar una ventana modal con los datos del personaje.
extends PopupPanel

## Etiqueta que muestra el titulo del personaje desbloqueado.
@onready var character_name_label = get_node("%UnlockedTittle")

## Imagen que muestra el icono del personaje desbloqueado.
@onready var character_image = get_node("%CharacterIcon")

## Boton para cerrar el popup y continuar.
@onready var continue_button = get_node("%OkButton")


## Muestra el popup con la informacion del personaje desbloqueado.
## [param char_data] Los datos del personaje que se acaba de desbloquear.
func show_character_unlock(char_data: CharacterData) -> void:
  
	## Actualiza los elementos de la interfaz de usuario
	character_name_label.text = char_data.character_name +  " it's joining the team!"
	character_image.texture = char_data.character_icon
	GameManager.play_sfx("res://audio/soundEffects/achievement.ogg")
	popup_centered()

## Se ejecuta cuando se presiona el boton OK.
## Oculta el popup y permite continuar con el juego.
func _on_ok_button_pressed() -> void:
	hide()