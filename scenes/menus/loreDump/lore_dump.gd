extends Control

@onready var lore_dump_text = get_node("%LoreDumpText")
@onready var mound_image = get_node("%Mounds")
@onready var rabbits_image = get_node("%Rabbits")
@onready var start_image = get_node("%Star")

var lore_progression: int
var event_bus
var lore_archive: Array[String] = ["In a quiet valley folded between forested hills and windswept meadows, the rabbits made their home. The land was gentle and full of hiding places—burrows tucked beneath tree roots, tall grasses swaying like green curtains, and shaded thickets where dew clung like tiny lanterns. Streams wove through the earth like silver threads, and the air was rich with the scent of moss and clover."
,"Life, though, was never easy for the rabbits. They were born into a world where danger moved on wings, padded on claws, or slithered through the underbrush. Every rustle might be a hawk, every shadow a fox. They learned early how to vanish, how to freeze their breath and melt into the stillness of the land. No matter how beautiful the valley was, it always pulsed with fear just beneath the soil.",
"Then one night, as a pale wind turned the grass to silver, a streak of light tore across the sky—silent, quick, and burning bright. Every rabbit in the valley saw it. Hearts thumping, they lifted their heads and, without speaking, wished. It wasn’t one wish, but many: for safety, for strength, for a life not ruled by fear. The light vanished behind the hills, and the valley fell quiet again."]
var tween: Tween

func _ready() -> void:
	# Set all images to invisible initially
	mound_image.modulate.a = 0.0
	rabbits_image.modulate.a = 0.0
	start_image.modulate.a = 0.0

func make_visible(bus):
	event_bus = bus
	lore_progression = 1
	self.visible = true
	progress_lore()

func progress_lore():
	match lore_progression:
		1:
			mound_image.visible = true
			fade_in_image(mound_image)
			lore_dump_text.text = lore_archive[0]
		2:
			rabbits_image.visible = true
			fade_in_image(rabbits_image)
			lore_dump_text.text = lore_archive[1]
		3:
			start_image.visible = true
			fade_in_image(start_image)
			lore_dump_text.text = lore_archive[2]
		4:
			fade_out_self()
			event_bus.emit_signal("fade_out_lore_dump")

func fade_in_image(image_node: Control):
	# Create a new tween for this fade-in
	tween = create_tween()
	# Fade in the image over 1 second
	tween.tween_property(image_node, "modulate:a", 1.0, 1.0)

func fade_out_self():
	# Create a new tween for fade out
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	# Hide the control after fade out completes
	tween.tween_callback(func(): self.visible = false)

func _on_continue_button_pressed():
	lore_progression += 1
	progress_lore()
