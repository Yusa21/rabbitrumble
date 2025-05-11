extends VBoxContainer

var event_bus
var ability_list

@onready var char_name_display = get_node("%CharName")
@onready var hp_display = get_node("%HPValue")
@onready var atk_display = get_node("%AtkValue")
@onready var def_display = get_node("%DefValue")
@onready var speed_display = get_node("%SpeedValue")
@onready var char_image_display = get_node("%CharacterImage")
@onready var char_description_display = get_node("%CharDescription")
@onready var ability_list_display = get_node("%AbilityList")
@onready var ability_information_display = get_node("%AbilityInformationUI")

func _ready() -> void:
	pass

func initialize(bus):
	event_bus = bus
	event_bus.character_clicked.connect(_on_character_clicked)
	event_bus.ability_clicked.connect(_on_ability_clicked)

	ability_list_display.initialize(event_bus)

func _on_character_clicked(char_data):
	#Pone los datos del personaje
	char_name_display.text = str(char_data.character_name)
	hp_display.text = str(char_data.max_hp)
	atk_display.text = str(char_data.attack)
	def_display.text = str(char_data.defense)
	speed_display.text = str(char_data.speed)
	char_description_display = str(char_data.character_description)
	char_image_display.texture = char_data.idle_sprite

	#Guarda la lista de habilidades y pone la primera en exposicion
	ability_list = char_data.abilities
	ability_information_display.update_ability_information_ui(ability_list[0])

func _on_ability_clicked(ability_data):
	ability_information_display.update_ability_information_ui(ability_data)
