extends Node2D
class_name BaseCharacter
#Inicializa los componentes del arbol
@onready var sprite: Sprite2D
@onready var animationPlayer: AnimationPlayer
@onready var area2D: Area2D
@onready var statusEffects: Node2D
@onready var ui: CanvasLayer

const player_alignment = "player"
const enemy_alignment = "enemy"
const other_alignment = "other"

const min_position = 1
const max_position = 4

#Estadisiticas que luego se cargan
var id
var char_name
var max_hp
var current_hp
var atk
var def
var speed
var abilities = []
var char_position
var has_taken_turn: bool = false
var ally_team = []
var opps_team = []

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
	abilities = character.abilities
	char_position = char_pos
	sprite.texture = character.idle_sprite
	return true

#Recibe los dos equipos y los guarda, el primero siempre es el propio
func set_teams(new_ally_team: Array, new_opps_team: Array):
	ally_team = new_ally_team
	opps_team = new_opps_team
	return true

#Debug only	
func print_character_stats():
	print("Character Stats:")
	print("Name: ", char_name)
	print("Max HP: ", max_hp)
	print("Attack: ", atk)
	print("Defense: ", def)
	print("Speed: ", speed)
	return true
	
'''
Codigo del combate
'''
#Funcion que hace lo que le toque al empezar el turno, siempre se sobreescribe
func start_turn():
	print("start_turn called directly, this function should be overriden")
	print_character_stats()
	return true

#Ejecuta la habilidad sabiendo a quien apunta
func execute_ability(ability, targeted_positions: Array):
	print(ability.target_type)
	var targets: Array
	#Esto es denso de cojones pero mira
	#Para los enemigos
	if(ability.target_type == "single_opp" || ability.target_type == "multiple_opps"):
		print("entra en single opps")
		#Recorro el equipo entero enemigo
		for opp in opps_team:
			#Buscando quien tiene la posicion que targeteo
			for char_position in targeted_positions:
				#Si coincide anado al personaje a la lista de targets y quito la posicion
				#de la lista porque ya esta cubierta
				if opp.char_position == char_position:
					targets.push_front(opp)
					targeted_positions.erase(char_position)
					break
				#Si esta vacia significa que ya esta todo encontrado no sigas buscando
				if targeted_positions.is_empty():
					break
	#Para aliados
	elif ability.target_type == "single_ally" || ability.target_type == "multiple_allies":
		print("targeting allies")
		for ally in ally_team:
			for char_position in targeted_positions:
				if ally.char_position == char_position:
					targets.push_front(ally)
					targeted_positions.erase(char_position)
					break
			if targeted_positions.is_empty():
				break
	
	# Para self
	elif ability.target_type == "self":
		print("targeting self")
		targets.push_front(self)  # Se anade directamente no hace falta buscar
	
	# Activa los efectos en los objetivos, comprueba que no este vacio por si acaso
	if !targets.is_empty():
		for effect in ability.effects:
			await effect.execute(self, ability.multiplier, targets)
		
		# Print del la vida del target, to rechulon porque escribe el equipo del que es
		if targets.size() > 0:
			var target_type = "Self" if targets[0] == self else ("Ally" if targets[0] in ally_team else "Enemy")
			print(target_type + " health: " + str(targets[0].current_hp))
	else:
		print("Error- Targets is empty - This should be imposible")
	
	return true

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

#Esta funcion se usa para moverse
func moving(starting_position, final_position, mover):
	#Corrige que el objetivo no se salga de las posiciones posibles
	if final_position > max_position:
		final_position = max_position
	elif final_position < min_position:
		final_position = min_position
		
	#Vector de movimiento se usa para saber cuanto y en que direccion se esta moviendo
	var movement_vector = final_position - starting_position
	#Lo mismo sin signo
	var absolute_vector
	#1 o -1 opuesto al signo del vector, se usa para mover a los personajes a los que les ha pasado por encima
	var side_correction
	if movement_vector < 0: 
		absolute_vector = -movement_vector
		side_correction = 1
	else: 
		absolute_vector = movement_vector
		side_correction = -1
	
	#Diccionarios con los personajes en orden, la key es la posicion
	var allies_positions = get_postions()
	
	#Si la posicion esta ocupada marcalo
	var position_occupied
	if allies_positions.has(final_position): position_occupied = true
	
	#Le pone la nueva posicion
	self.char_position = final_position
	
	#Si la posicion esta ocupada hay que mover a la gente para que todo encaje
	if (position_occupied):
		#Por cada posicion que se haya movido hay alguien a quien corregir
		for i in range(0, absolute_vector-1):
			#Busca quien esta en una posicion a corregir
			allies_positions.find_key(absolute_vector-i).moving_correction(side_correction) 
				
				
				
#Esta se usa para corregir posiciones tiene menos vueltas para ahorrar recursos
func moving_correction(step: int):
	self.char_position += step
	return true
	
#Funcion que devuelve un array con los personajes en la posicion correcta ordenada, recibiendo la 
#posicion inicial y final
func get_postions():
	#Busca si algun aliado comparte la misma posicion
	var char_list = {} 
	for ally in ally_team:
		char_list.set(ally.char_position, ally)
	return char_list

#TODO ni idea de que poner aquí aun
func add_status(status, dealer):
	return true
	
	
