extends Node
#---------------------USER DATA-------------------------------------------------------
var unlocked_char_list = ["testDummy","testDummy2","p_c_003","p_c_004","p_c_005","p_c_006"]
var unlocked_stage_list = ["test_stage", "test_stage_2"]
var completed_stage_list = ["test_stage"]

#----------------------MAIN MENU TRANSITION-------------------------------------------


#----------------------STAGE SELECTION TRANSITION-------------------------------------
func go_to_stage_select():
    get_tree().change_scene_to_file("res://scenes/menus/stageSelection/stage_selection.tscn")

#----------------------CHARACTER SELECTION TRANSITION---------------------------------
var stage_id = ["test_stage"]
var level_enemy_characters = ["testDummy2","testDummy2","testDummy2","testDummy2"]

func setup_character_select(level_enemies, id):
    level_enemy_characters = level_enemies
    stage_id = id

func go_to_character_select():
    get_tree().change_scene_to_file("res://scenes/menus/characterSelection/character_selection.tscn")

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

func end_battle():
    mark_stage_as_completed()
    go_to_stage_select()

func mark_stage_as_completed():
    if !completed_stage_list.has(stage_id):
        completed_stage_list.append(stage_id)
    
