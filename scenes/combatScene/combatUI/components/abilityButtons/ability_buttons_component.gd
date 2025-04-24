extends HBoxContainer
class_name AbilityButtonsComponent

var battle_event_bus: BattleEventBus
var current_character = null
var available_abilities: Array[AbilityData] = []

@onready var ability_button_1 = $AbilityButton1
@onready var ability_button_2 = $AbilityButton2

func _ready():
    # Initially disabled
    ability_button_1.disabled = true
    ability_button_2.disabled = true

func initialize(bus: BattleEventBus):
    battle_event_bus = bus
    
    # Connect to relevant events
    battle_event_bus.main_turn.connect(_on_main_turn)
    battle_event_bus.ability_target_chosen.connect(_on_ability_target_chosen)
 
func deactivate():
    ability_button_1.disabled = true
    ability_button_2.disabled = true

func _update_ability_buttons():
    if available_abilities.size() > 0:
        var can_use = available_abilities[0].get_launch_positions().has(current_character.char_position)
        ability_button_1.disabled = !can_use
        ability_button_1.text = available_abilities[0].name
    else:
        ability_button_1.disabled = true
        ability_button_1.text = "No Ability"
    
    if available_abilities.size() > 1:
        var can_use = available_abilities[1].get_launch_positions().has(current_character.char_position)
        ability_button_2.disabled = !can_use
        ability_button_2.text = available_abilities[1].name
    else:
        ability_button_2.disabled = true
        ability_button_2.text = "No Ability"

func _on_ability_button_1_pressed():
    if available_abilities.size() > 0:
        battle_event_bus.ability_selected.emit(current_character, available_abilities[0])

func _on_ability_button_2_pressed():
    if available_abilities.size() > 1:
        battle_event_bus.ability_selected.emit(current_character, available_abilities[1])

func _on_main_turn(character):
    #Comprueba que el personaje es un jugador
    if character and character.alignment == BattleConstants.Alignment.PLAYER:
        current_character = character
        available_abilities = character.abilities
        _update_ability_buttons()
    else:
        deactivate()

#Cuando se ha elegido un personaje ya no se puede elegir otro ataque, apaga los botones
func _on_ability_target_chosen(_ability, _target):
    deactivate()