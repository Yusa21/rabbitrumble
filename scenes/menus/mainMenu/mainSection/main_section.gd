extends VBoxContainer

var event_bus

func _ready() -> void:
	pass

func initialize(bus):
	event_bus = bus

func _on_start_button_pressed() -> void:
	event_bus.emit_signal("start_button_clicked")

func _on_exit_button_pressed() -> void:
	event_bus.emit_signal("exit_button_clicked")


