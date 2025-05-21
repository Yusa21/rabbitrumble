extends Control

@export var scroll_speed: float = 50.0  # Pixels per second
@export var direction: Vector2 = Vector2(-1, 0)  # Default: move left
@export var overlap_pixels: float = 1.0  # Overlap to prevent seam

@onready var texture_rect1 = $BackgroundTexture1
@onready var texture_rect2 = $BackgroundTexture2

func _ready():
    # Make sure both textures have the exact same settings
    texture_rect2.expand_mode = texture_rect1.expand_mode
    texture_rect2.stretch_mode = texture_rect1.stretch_mode
    
    # Position the second texture for continuous scrolling with slight overlap
    if direction.x < 0:  # Moving left
        texture_rect2.position.x = texture_rect1.size.x - overlap_pixels
    elif direction.x > 0:  # Moving right
        texture_rect2.position.x = -texture_rect1.size.x + overlap_pixels
        
    if direction.y < 0:  # Moving up
        texture_rect2.position.y = texture_rect1.size.y - overlap_pixels
    elif direction.y > 0:  # Moving down
        texture_rect2.position.y = -texture_rect1.size.y + overlap_pixels

func _process(delta):
    # Move both textures
    texture_rect1.position += direction.normalized() * scroll_speed * delta
    texture_rect2.position += direction.normalized() * scroll_speed * delta
    
    # Reset positions when needed with overlap
    var size = texture_rect1.size
    
    # Handle horizontal repositioning
    if direction.x < 0 and texture_rect1.position.x <= -size.x:
        texture_rect1.position.x = texture_rect2.position.x + size.x - overlap_pixels
    elif direction.x > 0 and texture_rect1.position.x >= size.x:
        texture_rect1.position.x = texture_rect2.position.x - size.x + overlap_pixels
        
    if direction.x < 0 and texture_rect2.position.x <= -size.x:
        texture_rect2.position.x = texture_rect1.position.x + size.x - overlap_pixels
    elif direction.x > 0 and texture_rect2.position.x >= size.x:
        texture_rect2.position.x = texture_rect1.position.x - size.x + overlap_pixels
    
    # Handle vertical repositioning
    if direction.y < 0 and texture_rect1.position.y <= -size.y:
        texture_rect1.position.y = texture_rect2.position.y + size.y - overlap_pixels
    elif direction.y > 0 and texture_rect1.position.y >= size.y:
        texture_rect1.position.y = texture_rect2.position.y - size.y + overlap_pixels
        
    if direction.y < 0 and texture_rect2.position.y <= -size.y:
        texture_rect2.position.y = texture_rect1.position.y + size.y - overlap_pixels
    elif direction.y > 0 and texture_rect2.position.y >= size.y:
        texture_rect2.position.y = texture_rect1.position.y - size.y + overlap_pixels