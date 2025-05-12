extends Control

var event_bus: StageSelectionBus
var unlocked_stage_list: Array[StageData]

@onready var stage_information_panel = get_node("%StageInformation")

func _ready() -> void:
	event_bus = StageSelectionBus.new()

	#Saca los personajes desbloqueados del game manager
	for stage_id in GameManager.unlocked_stage_list:
		unlocked_stage_list.append(StageRepo.load_stage_data_by_id(stage_id))
		
	stage_information_panel.initialize(event_bus)
	
	#Esto es mazo cutre pero asegura que muestre la primera mision al cargar
	event_bus.emit_signal("stage_clicked", unlocked_stage_list[0])