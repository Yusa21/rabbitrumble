class_name ShaderEffectManager
extends Node

@onready var sprite: Sprite2D = get_node("../Sprite2D")
var original_material: Material
var shader_materials: Dictionary = {}
var active_effect: String = ""
var effect_timer: float = 0.0
var effect_duration: float = 0.0

func _ready():
	original_material = sprite.material
	setup_shader_materials()

func _process(delta):
	if active_effect != "":
		effect_timer += delta
		
		# Auto-deactivate when duration is reached
		if effect_timer >= effect_duration:
			deactivate_effects()

func setup_shader_materials():
	# Damage shader setup
	var damage_shader = preload("res://shaders/damage_flash.gdshader")
	var damage_material = ShaderMaterial.new()
	damage_material.shader = damage_shader
	damage_material.set_shader_parameter("is_active", false)
	damage_material.set_shader_parameter("damage_color", Vector3(1.0, 0.2, 0.2))
	damage_material.set_shader_parameter("flash_duration", 0.6)
	shader_materials["damage"] = damage_material
	
	# Healing shader setup
	var healing_shader = preload("res://shaders/healing_wave.gdshader")
	var healing_material = ShaderMaterial.new()
	healing_material.shader = healing_shader
	healing_material.set_shader_parameter("is_active", false)
	healing_material.set_shader_parameter("healing_color", Vector3(0.2, 1.0, 0.3))
	healing_material.set_shader_parameter("wave_duration", 2.0)
	shader_materials["healing"] = healing_material

# Single method calls for AnimationPlayer
func trigger_damage_effect(duration: float = 0.6):
	"""Trigger damage flash effect"""
	_activate_effect("damage", duration)

func trigger_healing_effect(duration: float = 2.0):
	"""Trigger healing wave effect"""
	_activate_effect("healing", duration)

# Quick access methods for common use cases
func get_hurt():
	"""Quick method for hurt animation - 0.5 second damage flash"""
	trigger_damage_effect(0.5)

func get_healed():
	"""Quick method for heal animation - 1.0 second healing wave"""
	trigger_healing_effect(1.0)

func _activate_effect(effect_name: String, duration: float):
	"""Internal method to activate any effect"""
	print("Assigned material:", sprite.material)
	# Stop current effect if running
	if active_effect != "":
		_deactivate_current_effect()
	
	# Activate new effect
	active_effect = effect_name
	effect_timer = 0.0
	effect_duration = duration
	
	var material = shader_materials[effect_name] as ShaderMaterial
	sprite.material = material
	material.set_shader_parameter("is_active", true)
	material.set_shader_parameter("start_time", 0.0)  # Use relative time

func _deactivate_current_effect():
	"""Internal method to deactivate current effect"""
	if active_effect != "" and shader_materials.has(active_effect):
		var material = shader_materials[active_effect] as ShaderMaterial
		material.set_shader_parameter("is_active", false)

func stop_all_effects():
	"""Immediately stop any running shader effects"""
	_deactivate_current_effect()
	sprite.material = original_material
	active_effect = ""
	effect_timer = 0.0

func deactivate_effects():
	"""Smoothly deactivate effects (called automatically or manually)"""
	_deactivate_current_effect()
	sprite.material = original_material
	active_effect = ""
	effect_timer = 0.0

# Utility functions
func is_effect_active() -> bool:
	return active_effect != ""

func get_active_effect() -> String:
	return active_effect

func get_effect_progress() -> float:
	"""Returns progress of current effect (0.0 to 1.0)"""
	if active_effect == "" or effect_duration <= 0.0:
		return 0.0
	return min(effect_timer / effect_duration, 1.0)

# Configuration methods
func set_damage_color(color: Vector3):
	"""Set damage flash color"""
	if shader_materials.has("damage"):
		var material = shader_materials["damage"] as ShaderMaterial
		material.set_shader_parameter("damage_color", color)

func set_healing_color(color: Vector3):
	"""Set healing wave color"""
	if shader_materials.has("healing"):
		var material = shader_materials["healing"] as ShaderMaterial
		material.set_shader_parameter("healing_color", color)

func set_damage_duration(duration: float):
	"""Set damage flash duration"""
	if shader_materials.has("damage"):
		var material = shader_materials["damage"] as ShaderMaterial
		material.set_shader_parameter("flash_duration", duration)

func set_healing_duration(duration: float):
	"""Set healing wave duration"""
	if shader_materials.has("healing"):
		var material = shader_materials["healing"] as ShaderMaterial
		material.set_shader_parameter("wave_duration", duration)
