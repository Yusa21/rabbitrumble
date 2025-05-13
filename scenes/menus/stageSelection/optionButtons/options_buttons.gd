extends HBoxContainer

var event_bus

func _ready() -> void:
	pass

func initialize(bus):
	event_bus = bus

func _on_back_button_pressed() -> void:
	event_bus.emit_signal("back_button_clicked")
