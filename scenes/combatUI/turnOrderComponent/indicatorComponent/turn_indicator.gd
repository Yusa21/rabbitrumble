extends VBoxContainer
class_name TurnIndicator

# UI elements
@onready var character_icon = get_node("%CharacterIcon")
@onready var character_name = get_node("%CharacterName")

func initialize(character: BaseCharacter):
	# Update visuals
	if character != null:
		character_name.text = character.char_name
		character_icon.texture = character.character_icon
	#Aqui tambien haria falta poner texturas
