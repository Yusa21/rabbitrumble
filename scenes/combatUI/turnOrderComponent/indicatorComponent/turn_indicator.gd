extends Panel
class_name TurnIndicator

# UI elements
#@onready var character_icon = get_node("CharacterIcon")
@onready var character_name = get_node("CharacterName")

func initialize(character: BaseCharacter):
	# Update visuals
	if character != null:
		character_name.text = character.char_name
	#Aqui tambien haria falta poner texturas
