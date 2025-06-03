extends Node
## Maneja los efectos de shaders sobre el sprite del personaje.
## Esta clase se encarga de aplicar y gestionar diferentes efectos visuales
## como daño y curación mediante shaders en el sprite del jugador.
class_name ShaderEffectManager

## Nodo del sprite del personaje al que se aplicarán los efectos.
@onready var sprite: Sprite2D = get_node("../Sprite2D")

## Material original del sprite, guardado para poder restaurarlo.
var original_material: Material

## Diccionario con los posibles materiales que el shader puede usar.
## Almacena los diferentes ShaderMaterial configurados para cada efecto.
var shader_materials: Dictionary = {}

## Nombre del efecto que está activo actualmente.
var active_effect: String = ""

## Tiempo transcurrido desde que se activó el efecto actual.
var effect_timer: float = 0.0

## Duración total que debe durar el efecto activo.
var effect_duration: float = 0.0

## Se ejecuta cuando el nodo está listo.
## Inicializa el material original y configura los materiales de shader.
func _ready():
	original_material = sprite.material
	setup_shader_materials()

## Se ejecuta en cada frame.
## Gestiona el tiempo de los efectos activos y los desactiva automáticamente.
## [param delta] Tiempo transcurrido desde el último frame.
func _process(delta):
	if active_effect != "":
		effect_timer += delta
		
		# Desactivar automáticamente cuando se alcanza la duración
		if effect_timer >= effect_duration:
			deactivate_effects()

## Configura todos los materiales de shader disponibles.
## Crea y configura los ShaderMaterial para los efectos de daño y curación.
func setup_shader_materials():
	# Configuración del shader de daño
	var damage_shader = preload("res://shaders/damage_flash.gdshader")
	var damage_material = ShaderMaterial.new()
	damage_material.shader = damage_shader
	damage_material.set_shader_parameter("is_active", false)
	damage_material.set_shader_parameter("damage_color", Vector3(1.0, 0.2, 0.2))
	damage_material.set_shader_parameter("flash_duration", 0.6)
	shader_materials["damage"] = damage_material
	
	# Configuración del shader de curación
	var healing_shader = preload("res://shaders/healing_wave.gdshader")
	var healing_material = ShaderMaterial.new()
	healing_material.shader = healing_shader
	healing_material.set_shader_parameter("is_active", false)
	healing_material.set_shader_parameter("healing_color", Vector3(0.2, 1.0, 0.3))
	healing_material.set_shader_parameter("wave_duration", 2.0)
	shader_materials["healing"] = healing_material

## Activa el efecto de destello de daño.
## Método individual para llamadas desde AnimationPlayer.
## [param duration] Duración del efecto en segundos (por defecto 0.6).
func trigger_damage_effect(duration: float = 0.6):
	_activate_effect("damage", duration)

## Activa el efecto de onda de curación.
## Método individual para llamadas desde AnimationPlayer.
## [param duration] Duración del efecto en segundos (por defecto 2.0).
func trigger_healing_effect(duration: float = 2.0):
	_activate_effect("healing", duration)

## Método rápido para la animación de recibir daño.
## Aplica un destello de daño de 0.5 segundos.
func get_hurt():
	trigger_damage_effect(0.5)

## Método rápido para la animación de curación.
## Aplica una onda de curación de 1.0 segundo.
func get_healed():
	trigger_healing_effect(1.0)

## Método interno para activar cualquier efecto.
## [param effect_name] Nombre del efecto a activar.
## [param duration] Duración del efecto en segundos.
func _activate_effect(effect_name: String, duration: float):
	print("Material asignado:", sprite.material)
	# Detener el efecto actual si está ejecutándose
	if active_effect != "":
		_deactivate_current_effect()
	
	# Activar el nuevo efecto
	active_effect = effect_name
	effect_timer = 0.0
	effect_duration = duration
	
	var material = shader_materials[effect_name] as ShaderMaterial
	sprite.material = material
	material.set_shader_parameter("is_active", true)
	material.set_shader_parameter("start_time", 0.0)  # Usar tiempo relativo

## Metodo interno para desactivar el efecto actual.
## Desactiva el shader pero mantiene el material aplicado.
func _deactivate_current_effect():
	if active_effect != "" and shader_materials.has(active_effect):
		var material = shader_materials[active_effect] as ShaderMaterial
		material.set_shader_parameter("is_active", false)

## Detiene inmediatamente todos los efectos de shader en ejecución.
## Restaura el material original del sprite.
func stop_all_effects():
	_deactivate_current_effect()
	sprite.material = original_material
	active_effect = ""
	effect_timer = 0.0

## Desactiva suavemente los efectos.
## Se llama automáticamente o manualmente para finalizar efectos.
func deactivate_effects():
	_deactivate_current_effect()
	sprite.material = original_material
	active_effect = ""
	effect_timer = 0.0

## Verifica si hay algún efecto activo.
## [return] True si hay un efecto ejecutándose, False en caso contrario.
func is_effect_active() -> bool:
	return active_effect != ""

## Obtiene el nombre del efecto activo actual.
## [return] Nombre del efecto activo o cadena vacía si no hay ninguno.
func get_active_effect() -> String:
	return active_effect

## Devuelve el progreso del efecto actual.
## [return] Progreso del efecto de 0.0 a 1.0, donde 1.0 significa completado.
func get_effect_progress() -> float:
	if active_effect == "" or effect_duration <= 0.0:
		return 0.0
	return min(effect_timer / effect_duration, 1.0)

## Establece el color del destello de daño.
## [param color] Color del efecto como Vector3 (R, G, B en rango 0.0-1.0).
func set_damage_color(color: Vector3):
	if shader_materials.has("damage"):
		var material = shader_materials["damage"] as ShaderMaterial
		material.set_shader_parameter("damage_color", color)

## Establece el color de la onda de curación.
## [param color] Color del efecto como Vector3 (R, G, B en rango 0.0-1.0).
func set_healing_color(color: Vector3):
	if shader_materials.has("healing"):
		var material = shader_materials["healing"] as ShaderMaterial
		material.set_shader_parameter("healing_color", color)

## Establece la duración del destello de daño.
## [param duration] Duración del efecto en segundos.
func set_damage_duration(duration: float):
	if shader_materials.has("damage"):
		var material = shader_materials["damage"] as ShaderMaterial
		material.set_shader_parameter("flash_duration", duration)

## Establece la duración de la onda de curación.
## [param duration] Duración del efecto en segundos.
func set_healing_duration(duration: float):
	if shader_materials.has("healing"):
		var material = shader_materials["healing"] as ShaderMaterial
		material.set_shader_parameter("wave_duration", duration)