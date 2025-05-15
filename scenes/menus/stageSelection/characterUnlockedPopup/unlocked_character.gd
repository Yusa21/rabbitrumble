extends PopupPanel

@onready var character_name_label = get_node("%UnlockedTittle")
@onready var character_image = get_node("%CharacterIcon")
@onready var continue_button = get_node("%OkButton")


# Call this function to show the popup with the unlocked character info
func show_character_unlock(char_data: CharacterData) -> void:
  
	# Update the UI elements
	character_name_label.text = char_data.character_name +  " it's joining the team!"
	character_image.texture = char_data.character_icon

	popup_centered()
func _on_ok_button_pressed() -> void:
	hide()
