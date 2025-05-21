extends Control

@export var scroll_speed: float = 50.0  # Pixels per second
@export var direction: Vector2 = Vector2(-1, 0)  # Default: move left

@onready var texture_rect1 = $BackgroundTexture1
@onready var texture_rect2 = $BackgroundTexture2

func _ready():
	# Position the second texture for continuous scrolling
	if direction.x < 0:  # Moving left
		texture_rect2.position.x = texture_rect1.size.x
	elif direction.x > 0:  # Moving right
		texture_rect2.position.x = -texture_rect1.size.x
		
	if direction.y < 0:  # Moving up
		texture_rect2.position.y = texture_rect1.size.y
	elif direction.y > 0:  # Moving down
		texture_rect2.position.y = -texture_rect1.size.y

func _process(delta):
	# Move both textures
	texture_rect1.position += direction.normalized() * scroll_speed * delta
	texture_rect2.position += direction.normalized() * scroll_speed * delta
	
	# Reset positions when needed
	var size = texture_rect1.size
	
	# Handle horizontal repositioning
	if direction.x < 0 and texture_rect1.position.x <= -size.x:
		texture_rect1.position.x = texture_rect2.position.x + size.x
	elif direction.x > 0 and texture_rect1.position.x >= size.x:
		texture_rect1.position.x = texture_rect2.position.x - size.x
		
	if direction.x < 0 and texture_rect2.position.x <= -size.x:
		texture_rect2.position.x = texture_rect1.position.x + size.x
	elif direction.x > 0 and texture_rect2.position.x >= size.x:
		texture_rect2.position.x = texture_rect1.position.x - size.x
	
	# Handle vertical repositioning
	if direction.y < 0 and texture_rect1.position.y <= -size.y:
		texture_rect1.position.y = texture_rect2.position.y + size.y
	elif direction.y > 0 and texture_rect1.position.y >= size.y:
		texture_rect1.position.y = texture_rect2.position.y - size.y
		
	if direction.y < 0 and texture_rect2.position.y <= -size.y:
		texture_rect2.position.y = texture_rect1.position.y + size.y
	elif direction.y > 0 and texture_rect2.position.y >= size.y:
		texture_rect2.position.y = texture_rect1.position.y - size.y
