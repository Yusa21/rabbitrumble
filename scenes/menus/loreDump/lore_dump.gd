extends Control

# Referencias a nodos de UI
@onready var lore_dump_text = get_node("%LoreDumpText")  ## Caja de texto donde se muestra la narrativa
@onready var mound_image = get_node("%Mounds")           ## Imagen de los monticulos
@onready var rabbits_image = get_node("%Rabbits")        ## Imagen de los conejos
@onready var start_image = get_node("%Star")             ## Imagen de la estrella fugaz

# Variables de estado
var lore_progression: int                                ## Controla en que parte de la historia estamos
var event_bus                                             ## Bus de eventos para emitir señales
var lore_archive: Array[String] = [                      ## Lista con los textos de narrativa en orden
	"In a quiet valley folded between forested hills and windswept meadows, the rabbits made their home. The land was gentle and full of hiding places—burrows tucked beneath tree roots, tall grasses swaying like green curtains, and shaded thickets where dew clung like tiny lanterns. Streams wove through the earth like silver threads, and the air was rich with the scent of moss and clover.",
	"Life, though, was never easy for the rabbits. They were born into a world where danger moved on wings, padded on claws, or slithered through the underbrush. Every rustle might be a hawk, every shadow a fox. They learned early how to vanish, how to freeze their breath and melt into the stillness of the land. No matter how beautiful the valley was, it always pulsed with fear just beneath the soil.",
	"Then one night, as a pale wind turned the grass to silver, a streak of light tore across the sky—silent, quick, and burning bright. Every rabbit in the valley saw it. Hearts thumping, they lifted their heads and, without speaking, wished. It wasn’t one wish, but many: for safety, for strength, for a life not ruled by fear. The light vanished behind the hills, and the valley fell quiet again."
]
var tween: Tween                                           ## Tween para animaciones de aparicion/desaparicion

func _ready() -> void:
	## Al comenzar, las imagenes estan ocultas (alpha = 0)
	mound_image.modulate.a = 0.0
	rabbits_image.modulate.a = 0.0
	start_image.modulate.a = 0.0

## Hace visible el panel de historia e inicia la narrativa
## [param bus] Referencia al bus de eventos para emitir señales
func make_visible(bus):
	event_bus = bus
	lore_progression = 1
	self.visible = true
	progress_lore()

## Muestra progresivamente el contenido de la historia segun lore_progression
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

## Aplica efecto de aparicion a una imagen
## [param image_node] Nodo de tipo Control al que se le hara fade-in
func fade_in_image(image_node: Control):
	tween = create_tween()
	tween.tween_property(image_node, "modulate:a", 1.0, 1.0)

## Oculta completamente este nodo con una animacion de fade-out
func fade_out_self():
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): self.visible = false)

## Avanza al siguiente bloque de narrativa cuando se presiona el boton
func _on_continue_button_pressed():
	lore_progression += 1
	progress_lore()
