extends HBoxContainer

var stage_number_display
var stage_name_display
var completed_check_display
var stage_difficulty_display
var stage_data

# Make sure the control is set to process input
func _init():
	mouse_filter = Control.MOUSE_FILTER_STOP

func _ready() -> void:
	# Find child nodes after duplication
	stage_number_display = get_node_or_null("StageNumber")
	stage_name_display = get_node_or_null("StageName")
	completed_check_display = get_node_or_null("CompletedCheck")
	stage_difficulty_display = get_node_or_null("StageDifficulty")
	
	# Debug info
	if stage_number_display == null:
		print("Warning: StageNumber node not found in ", get_path())

func initialize(stage_number, stage_name, stage_difficulty, completed, stage_data_ref=null):
	# Store the stage data for reference when clicked
	stage_data = stage_data_ref
	
	# Make sure all node references are valid before accessing them
	if stage_number_display:
		stage_number_display.text = str(stage_number)  # Convert to string to be safe
	else:
		print("Error: stage_number_display is null")
		
	if stage_name_display:
		stage_name_display.text = stage_name
	
	if stage_difficulty_display:
		stage_difficulty_display.text = str(stage_difficulty)
   
	# Show or hide the completion check if it exists
	if completed_check_display:
		completed_check_display.visible = completed
	else:
		print("Error: completed_check_display is null")

# Override _gui_input to handle clicks directly
func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Stage clicked directly: ", stage_data)
		# The parent will handle the signal through the connected _on_stage_selected
