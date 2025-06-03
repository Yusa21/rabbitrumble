extends VBoxContainer
## Indicador visual de turno que muestra el icono y nombre de un personaje.
class_name TurnIndicator

## Elementos de la interfaz

## Referencia al nodo de icono del personaje.
@onready var character_icon = get_node("%CharacterIcon")

## Referencia al nodo de nombre del personaje.
@onready var character_name = get_node("%CharacterName")

## Inicializa el indicador visual con la informacion del personaje.
## [param character] Instancia del personaje cuyas estadisticas se mostraran.
func initialize(character: BaseCharacter):
	if character != null:
		character_name.text = character.char_name
		character_icon.texture = character.character_icon
