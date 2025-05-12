extends HBoxContainer

var event_bus

@onready var template_icon = get_node("%TemplateEnemyIcon")
@onready var default_icon = template_icon.texture

func _ready() -> void:
	pass

func initialize(bus):
	event_bus = bus
	event_bus.stage_clicked.connect(_on_stage_clicked)

	if !template_icon:
		push_error("Template button not found")
	
	template_icon.visible = false

func _on_stage_clicked(stage):
	update_enemy_preview(stage)

func update_enemy_preview(stage):
	var char_list = get_char_list(stage)

	for child in get_children():
		if child!= template_icon:
			child.queue_free()

	for character in char_list:
		var new_icon = template_icon.duplicate()
		new_icon.visible = true

		if character.character_icon != null:
			new_icon.texture = character.character_icon
		else:
			new_icon.texture = default_icon

		add_child(new_icon)

func get_char_list(stage):
	var char_list: Array

	for char_id in stage.enemies:
		var new_enemy = CharacterRepo.load_character_data_by_id(char_id)
		if new_enemy != null:
			char_list.append(new_enemy)
		else:
			push_error("Enemy with id: " + str(char_id) + "not found")

	return char_list
