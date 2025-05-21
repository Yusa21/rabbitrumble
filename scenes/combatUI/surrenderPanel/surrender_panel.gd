extends PopupPanel

var event_bus

func _ready() -> void:
	exclusive = true
	pass

func initialize(bus) -> void:
	event_bus = bus

func show_surrender_popup() -> void:
	popup_centered()

func hide_surrender_popup() -> void:
	hide()

func _on_surrender_button_pressed() -> void:
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	event_bus.emit_signal("giving_up")

func _on_continue_button_pressed() -> void:
	GameManager.play_sfx("res://audio/soundEffects/bleep.ogg")
	hide_surrender_popup()
