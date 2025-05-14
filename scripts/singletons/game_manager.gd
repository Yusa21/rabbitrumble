extends Node
#---------------------USER DATA-------------------------------------------------------
var unlocked_char_list = ["testDummy","testDummy2","p_c_003","p_c_004","p_c_005","p_c_006"]
var unlocked_stage_list = ["test_stage", "test_stage_2"]
var completed_stage_list = ["test_stage"]

#----------------------MAIN MENU TRANSITION-------------------------------------------
func go_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/menus/mainMenu/main_menu.tscn")

#----------------------STAGE SELECTION TRANSITION-------------------------------------
var new_chars_unlocked: Array[String]
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
	check_unlocks()
	save_game()
	go_to_stage_select()

func mark_stage_as_completed():
	if !completed_stage_list.has(stage_id):
		completed_stage_list.append(stage_id)

func check_unlocks():
	var stage_data = StageRepo.load_stage_data_by_id(stage_id)
	if stage_data.char_unlocks != [""]:
		for char_id in stage_data.char_unlocks:
			if !char_id in unlocked_char_list:
				new_chars_unlocked.append(char_id)
				unlocked_char_list.append(char_id)
	
	if stage_data.stage_unlocks != [""]:
		for unlocked_stage_id in stage_data.stage_unlocks:
			if !unlocked_stage_id in unlocked_stage_id:
				unlocked_stage_list.append(unlocked_stage_id)

#-----------------------------SAVE DATA MANAGEMENT--------------------------------
func save_game():
	var save_data = GameSave.new()
	save_data.unlocked_char_list = unlocked_char_list
	save_data.unlocked_stage_list = unlocked_stage_list
	save_data.completed_stage_list = completed_stage_list

	var error = ResourceSaver.save(save_data, "user://save_game.tres")
	if error != OK:
		push_error("Failed to save game: ", error)
		return false
	return true


func load_game():
	if not FileAccess.file_exists("user://save_game.tres"):
		create_default_save_file()
		return true
		
	var save_data = load("user://save_game.tres")
	if not save_data:
		push_error("Failed to load save file")
		return false

	unlocked_char_list = save_data.unlocked_char_list
	unlocked_stage_list = save_data.unlocked_stage_list
	completed_stage_list = save_data.completed_stage_list

	print("Loaded game")

	return true

const default_char_list: Array[String] = ["testDummy2","p_c_003","p_c_004"]
const default_stage_list: Array[String] = ["test_stage"]
const default_completed_list: Array[String] = [""]

func create_default_save_file():
	var save_data = GameSave.new()
	save_data.unlocked_char_list = default_char_list
	save_data.unlocked_stage_list = default_stage_list
	save_data.completed_stage_list = default_completed_list

	var error = ResourceSaver.save(save_data, "user://save_game.tres")
	if error != OK:
		push_error("Failed to create new save file: ", error)
		return false

	unlocked_char_list = default_char_list
	unlocked_stage_list = default_stage_list
	completed_stage_list = default_completed_list

	print("Save file created")
	return true
	
