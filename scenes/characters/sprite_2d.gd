## Sprite2D personalizado con efectos visuales y de sonido.
## Maneja el escalado automático del sprite y proporciona efectos de destello de daño
## y ondas de curaciOn mediante shaders animados.
extends Sprite2D

## Tamaño objetivo al que se debe escalar el sprite.
@export var target_size := Vector2(60,60)

## Material shader utilizado para el efecto de destello de daño.
@export var damage_shader_material: ShaderMaterial

## Material shader utilizado para el efecto de onda de curación.
@export var healing_shader_material: ShaderMaterial

## Material original del sprite antes de aplicar efectos.
var original_material: Material

## Tween actual que se está ejecutando para los efectos.
var current_tween: Tween

## Inicializa el sprite escalándolo al tamaño objetivo y guardando el material original.
func _ready():
	scale_sprite_to_size(target_size)
	original_material = material

## Escala el sprite para ajustarse al tamaño especificado manteniendo la proporción.
## [param size] El tamaño objetivo en píxeles.
func scale_sprite_to_size(size: Vector2):
	if texture:
		var texture_size = texture.get_size()
		var scale_ratio = min(size.x / texture_size.x, size.y / texture_size.y)
		scale = Vector2.ONE * scale_ratio

## Reproduce un sonido utilizando el GameManager.
## [param sound_name] El nombre del archivo de sonido sin extensión.
func play_sound(sound_name):
	const sound_path_pre = "res://audio/soundEffects/"
	const sound_path_post = ".ogg"
	GameManager.play_sfx(sound_path_pre + sound_name + sound_path_post)

## Reproduce un efecto de destello de dano.
## Aplica el shader de dano y anima la intensidad del destello con un efecto
## rapido de aparición y desvanecimiento más lento.
func play_damage_flash():
	if current_tween:
		current_tween.kill()
	
	# Establecer el shader de dano
	material = damage_shader_material
	
	# Crear y configurar el tween
	current_tween = create_tween()
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.set_trans(Tween.TRANS_QUART)
	
	# Efecto de destello: destello rapido, desvanecimiento lento
	current_tween.tween_method(_set_flash_intensity, 0.0, 1.0, 0.1)
	current_tween.tween_method(_set_flash_intensity, 1.0, 0.0, 0.4)
	current_tween.tween_callback(_reset_material)

## Reproduce un efecto de onda de curacion.
## Aplica el shader de curación y anima el progreso de la onda con una trasicion
func play_healing_wave():
	if current_tween:
		current_tween.kill()
	
	# Establecer el shader de curación
	material = healing_shader_material
	
	# Crear y configurar el tween
	current_tween = create_tween()
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.set_trans(Tween.TRANS_SINE)
	
	# Efecto de onda: progresión suave de 0 a 1
	current_tween.tween_method(_set_wave_progress, 0.0, 1.0, 0.5)
	current_tween.tween_callback(_reset_material)

## Establece la intensidad del destello en el shader de daño.
## [param value] Valor de intensidad entre 0.0 y 1.0.
func _set_flash_intensity(value: float):
	if damage_shader_material:
		damage_shader_material.set_shader_parameter("flash_intensity", value)

## Establece el progreso de la onda en el shader de curacion.
## [param value] Valor de progreso entre 0.0 y 1.0.
func _set_wave_progress(value: float):
	if healing_shader_material:
		healing_shader_material.set_shader_parameter("wave_progress", value)

## Restaura el material original del sprite despues de los efectos.
func _reset_material():
	material = original_material