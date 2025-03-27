extends Node2D
class_name BaseCharacter
#Inicializa los componentes del arbol
@onready var sprite: Sprite2D
@onready var animationPlayer: AnimationPlayer
@onready var area2D: Area2D
@onready var statusEffects: Node2D
@onready var ui: CanvasLayer

#Estadisiticas que luego se cargan
var id
var char_name
var max_hp
var current_hp
var atk
var def
var speed
var char_position
var has_taken_turn: bool = false
var team = []

#TODO DEBUG
#func _ready():
	#initialize_character("testDumy", 0)

'''
Codigo de inicializacion
'''
#Crea una escena de personaje usando el id del recurso a usar el id para identificarlo en combate
func initialize_character(char_data_id: String, new_id: int, char_pos: int):
	#Inicializa los nodos hijos
	sprite = get_node("Sprite2D")
	animationPlayer = get_node("AnimationPlayer")
	area2D = get_node("Area2D")
	statusEffects = get_node("StatusEffects")
	ui = get_node("CanvasLayer")
	
	#Llama al repositorio de personajes para cargar sus datos
	var character = CharacterRepo.load_character_data_by_id(char_data_id)
	if character == null:
		print("Character not found")
		return null
	set_character_info(character,new_id, char_pos)
	return true

#Recibe un characterData y un id para inicializar las variables del personaje
func set_character_info(character: CharacterData, new_id: int, char_pos: int):
	id = new_id
	char_name = character.character_name
	max_hp = character.max_hp
	current_hp = character.max_hp
	atk = character.attack
	def = character.defense
	speed = character.speed
	char_position = char_pos
	sprite.texture = character.idle_sprite

#Debug only	
func print_character_stats():
	print("Character Stats:")
	print("Name: ", char_name)
	print("Max HP: ", max_hp)
	print("Attack: ", atk)
	print("Defense: ", def)
	print("Speed: ", speed)
	
'''
Codigo del combate
'''
#Funcion que hace lo que le toque al empezar el turno, siempre se sobreescribe
func start_turn():
	print_character_stats()

#TODO le faltaria triggers y cosas por el estilo
func take_damage(dmg, atacker):
	current_hp -= dmg
	if current_hp < 0:
		current_hp = 0
	return true
	
func take_healing(heal, healer):
	current_hp += heal
	if current_hp > max_hp:
		current_hp = max_hp
	return true

#TODO ni idea de que poner aquí aún
func add_status(status, dealer):
	return true
	
	
