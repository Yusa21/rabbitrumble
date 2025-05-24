extends Sprite2D

@export var target_size := Vector2(60,60)

func _ready():
	scale_sprite_to_size(target_size)

func scale_sprite_to_size(size: Vector2):
	if texture:
		var texture_size = texture.get_size()
		var scale_ratio = min(size.x / texture_size.x, size.y / texture_size.y)
		scale = Vector2.ONE * scale_ratio


func play_sound(sound_name):
	const sound_path_pre = "res://audio/soundEffects/"
	const sound_path_post = ".ogg"
	GameManager.play_sfx(sound_path_pre + sound_name + sound_path_post)
