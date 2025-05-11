extends Node
#---------------------USER DATA-------------------------------------------------------
var unlocked_char_list = ["testDummy","testDummy","testDummy","testDummy","testDummy","testDummy2","testDummy2","testDummy2","testDummy2"]


#----------------------STAGE INFORMATION---------------------------------------------
var level_enemy_characters = ["testDummy2","testDummy2","testDummy2","testDummy2"]

#---------------------BATTLE DATA TRANSITION------------------------------------------
# Data that will be passed from menu to battle
var selected_player_characters = ["testDummy","testDummy","testDummy","testDummy"]
var selected_enemy_characters = ["testDummy2","testDummy2","testDummy2","testDummy2"]

# Function to set up a new battle
func setup_battle(players, enemies):
    selected_player_characters = players
    selected_enemy_characters = enemies

# Function to start the battle scene
func start_battle():
    # Transition to battle scene
    get_tree().change_scene_to_file("res://scenes/combatScene/Battle.tscn")
