extends Control

var event_bus: StageSelectionBus
var unlocked_stage_list: Array[StageData]
var completed_stage_list: Array = GameManager.completed_stage_list

@onready var stage_list_display = get_node("%StageList")
@onready var stage_information_panel = get_node("%StageInformation")

func _ready() -> void:
	event_bus = StageSelectionBus.new()

	#Saca los personajes desbloqueados del game manager
	for stage_id in GameManager.unlocked_stage_list:
		var unlocked_stage = StageRepo.load_stage_data_by_id(stage_id)
		if unlocked_stage != null:
			unlocked_stage_list.append(StageRepo.load_stage_data_by_id(stage_id))
		else:
			push_error("Unlocked stage with id: " + unlocked_stage + " doesn't exists")
		
		
	stage_list_display.initialize(event_bus, unlocked_stage_list, completed_stage_list)
	stage_information_panel.initialize(event_bus)
	
	#Esto es mazo cutre pero asegura que muestre la primera mision al cargar
	event_bus.emit_signal("stage_clicked", unlocked_stage_list[0])
