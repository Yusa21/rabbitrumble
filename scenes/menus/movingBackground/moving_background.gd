extends Control

@export var scroll_speed: float = 50.0
@export var direction: Vector2 = Vector2(-1, 0)
@export var overlap_pixels: float = 1.0

@onready var texture_rect1 = $BackgroundTexture1
@onready var texture_rect2 = $BackgroundTexture2

# Static variable to persist across instances
static var background_state: BackgroundState = BackgroundState.new()

func _ready():
	# Make sure both textures have the exact same settings
	texture_rect2.expand_mode = texture_rect1.expand_mode
	texture_rect2.stretch_mode = texture_rect1.stretch_mode
	
	# Initialize positions if this is the first time
	if not background_state.is_initialized:
		background_state.position1 = Vector2.ZERO
		
		if direction.x < 0:  # Moving left
			background_state.position2.x = texture_rect1.size.x - overlap_pixels
		elif direction.x > 0:  # Moving right
			background_state.position2.x = -texture_rect1.size.x + overlap_pixels
			
		if direction.y < 0:  # Moving up
			background_state.position2.y = texture_rect1.size.y - overlap_pixels
		elif direction.y > 0:  # Moving down
			background_state.position2.y = -texture_rect1.size.y + overlap_pixels
			
		background_state.is_initialized = true
	
	# Set positions from stored state
	texture_rect1.position = background_state.position1
	texture_rect2.position = background_state.position2

func _process(delta):
	# Move both textures
	background_state.position1 += direction.normalized() * scroll_speed * delta
	background_state.position2 += direction.normalized() * scroll_speed * delta
	
	# Apply positions to textures
	texture_rect1.position = background_state.position1
	texture_rect2.position = background_state.position2
	
	# Reset positions when needed with overlap
	var size = texture_rect1.size
	
	# Handle horizontal repositioning
	if direction.x < 0 and background_state.position1.x <= -size.x:
		background_state.position1.x = background_state.position2.x + size.x - overlap_pixels
	elif direction.x > 0 and background_state.position1.x >= size.x:
		background_state.position1.x = background_state.position2.x - size.x + overlap_pixels
		
	if direction.x < 0 and background_state.position2.x <= -size.x:
		background_state.position2.x = background_state.position1.x + size.x - overlap_pixels
	elif direction.x > 0 and background_state.position2.x >= size.x:
		background_state.position2.x = background_state.position1.x - size.x + overlap_pixels
	
	# Handle vertical repositioning
	if direction.y < 0 and background_state.position1.y <= -size.y:
		background_state.position1.y = background_state.position2.y + size.y - overlap_pixels
	elif direction.y > 0 and background_state.position1.y >= size.y:
		background_state.position1.y = background_state.position2.y - size.y + overlap_pixels
		
	if direction.y < 0 and background_state.position2.y <= -size.y:
		background_state.position2.y = background_state.position1.y + size.y - overlap_pixels
	elif direction.y > 0 and background_state.position2.y >= size.y:
		background_state.position2.y = background_state.position1.y - size.y + overlap_pixels