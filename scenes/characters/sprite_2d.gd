extends Sprite2D

@export var target_size := Vector2(60,60)

func _ready():
    scale_sprite_to_size(target_size)

func scale_sprite_to_size(size: Vector2):
    if texture:
        var texture_size = texture.get_size()
        scale = size / texture_size