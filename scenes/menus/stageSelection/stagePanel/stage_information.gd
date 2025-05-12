extends VBoxContainer
class_name StageInformationPanel

var event_bus

@onready var name_display = get_node("%StageName")
@onready var difficulty_display = get_node("%StageDifficulty")
@onready var enemy_team_preview = get_node("%EnemyTeamPreview")
@onready var description_display = get_node("%StageDescription")
@onready var completed_check = get_node("%CompletedCheck")

func _ready() -> void:
	pass

func initialize(bus):
	event_bus = bus

	enemy_team_preview.initialize(bus)
	event_bus.stage_clicked.connect(_on_stage_clicked)

func _on_stage_clicked(stage: StageData):
	_update_stage_information(stage)

func _on_start_button_pressed() -> void:
	event_bus.emit_signal("start_button_clicked")

func _update_stage_information(stage: StageData):
	name_display.text = str(stage.name)
	difficulty_display.text = str(stage.difficulty)
	description_display.text = str(stage.description)
	if stage.id in GameManager.completed_stage_list:
		completed_check.visible = true
	else:
		completed_check.visible = false
