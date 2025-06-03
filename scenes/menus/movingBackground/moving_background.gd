extends Control

## Velocidad del desplazamiento del fondo.
@export var scroll_speed: float = 50.0
## Dirección del desplazamiento. Por ejemplo, (-1, 0) para la izquierda.
@export var direction: Vector2 = Vector2(-1, 0)
## Número de píxeles que se superponen entre texturas para un scroll sin costuras.
@export var overlap_pixels: float = 1.0

@onready var texture_rect1 = $BackgroundTexture1
@onready var texture_rect2 = $BackgroundTexture2

## Estado persistente del fondo entre instancias.
static var background_state: BackgroundState = BackgroundState.new()

func _ready():
	# Asegurar que ambas texturas tengan la misma configuración
	texture_rect2.expand_mode = texture_rect1.expand_mode
	texture_rect2.stretch_mode = texture_rect1.stretch_mode

	# Inicializar posiciones solo una vez
	if not background_state.is_initialized:
		background_state.position1 = Vector2.ZERO

		# Posicionar la segunda textura en función de la dirección
		if direction.x < 0:
			background_state.position2.x = texture_rect1.size.x - overlap_pixels
		elif direction.x > 0:
			background_state.position2.x = -texture_rect1.size.x + overlap_pixels

		if direction.y < 0:
			background_state.position2.y = texture_rect1.size.y - overlap_pixels
		elif direction.y > 0:
			background_state.position2.y = -texture_rect1.size.y + overlap_pixels

		background_state.is_initialized = true

	# Aplicar las posiciones almacenadas
	texture_rect1.position = background_state.position1
	texture_rect2.position = background_state.position2

func _process(delta: float) -> void:
	# Mover ambas texturas
	background_state.position1 += direction.normalized() * scroll_speed * delta
	background_state.position2 += direction.normalized() * scroll_speed * delta

	# Aplicar las nuevas posiciones
	texture_rect1.position = background_state.position1
	texture_rect2.position = background_state.position2

	var size = texture_rect1.size

	# Reposicionar horizontalmente si es necesario
	if direction.x < 0 and background_state.position1.x <= -size.x:
		background_state.position1.x = background_state.position2.x + size.x - overlap_pixels
	elif direction.x > 0 and background_state.position1.x >= size.x:
		background_state.position1.x = background_state.position2.x - size.x + overlap_pixels

	if direction.x < 0 and background_state.position2.x <= -size.x:
		background_state.position2.x = background_state.position1.x + size.x - overlap_pixels
	elif direction.x > 0 and background_state.position2.x >= size.x:
		background_state.position2.x = background_state.position1.x - size.x + overlap_pixels

	# Reposicionar verticalmente si es necesario
	if direction.y < 0 and background_state.position1.y <= -size.y:
		background_state.position1.y = background_state.position2.y + size.y - overlap_pixels
	elif direction.y > 0 and background_state.position1.y >= size.y:
		background_state.position1.y = background_state.position2.y - size.y + overlap_pixels

	if direction.y < 0 and background_state.position2.y <= -size.y:
		background_state.position2.y = background_state.position1.y + size.y - overlap_pixels
	elif direction.y > 0 and background_state.position2.y >= size.y:
		background_state.position2.y = background_state.position1.y - size.y + overlap_pixels
