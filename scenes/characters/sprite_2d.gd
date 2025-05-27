extends Sprite2D

@export var target_size := Vector2(60,60)
@export var damage_shader_material: ShaderMaterial
@export var healing_shader_material: ShaderMaterial

var original_material: Material
var current_tween: Tween

func _ready():
	scale_sprite_to_size(target_size)
	original_material = material

func scale_sprite_to_size(size: Vector2):
	if texture:
		var texture_size = texture.get_size()
		var scale_ratio = min(size.x / texture_size.x, size.y / texture_size.y)
		scale = Vector2.ONE * scale_ratio


func play_sound(sound_name):
	const sound_path_pre = "res://audio/soundEffects/"
	const sound_path_post = ".ogg"
	GameManager.play_sfx(sound_path_pre + sound_name + sound_path_post)

func play_damage_flash():
	if current_tween:
		current_tween.kill()
	
	# Set the damage shader
	material = damage_shader_material
	
	# Create and configure the tween
	current_tween = create_tween()
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.set_trans(Tween.TRANS_QUART)
	
	# Flash effect: quick flash in, slower fade out
	current_tween.tween_method(_set_flash_intensity, 0.0, 1.0, 0.1)
	current_tween.tween_method(_set_flash_intensity, 1.0, 0.0, 0.4)
	current_tween.tween_callback(_reset_material)

func play_healing_wave():
	if current_tween:
		current_tween.kill()
	
	# Set the healing shader
	material = healing_shader_material
	
	# Create and configure the tween
	current_tween = create_tween()
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.set_trans(Tween.TRANS_SINE)
	
	# Wave effect: smooth progression from 0 to 1
	current_tween.tween_method(_set_wave_progress, 0.0, 1.0, 0.5)
	current_tween.tween_callback(_reset_material)

func _set_flash_intensity(value: float):
	if damage_shader_material:
		damage_shader_material.set_shader_parameter("flash_intensity", value)

func _set_wave_progress(value: float):
	if healing_shader_material:
		healing_shader_material.set_shader_parameter("wave_progress", value)

func _reset_material():
	material = original_material