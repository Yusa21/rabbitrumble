extends Node2D
class_name BaseCharacter
##Clase que representa un personaje involucrado en un combate
##
##Contiene el codigo de iniciciacion del personaje (quizas habria que moverlo a otra parte) y 
##todas las funciones que hacer falta para que los personajes puedan funcionar, como recibir dano, moverse...
##tambien tiene algunas funciones que se sobreescriben en las clases hija como las de que ocurre cuando empieza un turno

@onready var sprite: Sprite2D
@onready var animationPlayer: AnimationPlayer
@onready var area2D: Area2D
@onready var statusEffects: Node2D

##Formations manager para que los personajes puedan aparecer en pantalla en los lugares correctos
var formations_manager = null

##Bus de eventos
var event_bus = null


#Estadisiticas que luego se cargan
var id: int ##Id de la INSTANCIA especifica de personaje
var alignment: BattleConstants.Alignment ##A que equipo pertenece el personaje, se le da valor en las subclases
var char_name: String ##Nombre del personaje
var max_hp: int ##Salud maxima
var current_hp: int ##Salud actual
var atk: int ##Ataque del personaje
var def: int ##Defensa del personaje
var speed: int ##Velocidad del personaje
var abilities: Array[AbilityData] ## Habilidades que el personaje tiene disponibles
var char_position: int ##Posicion que ocupa el personaje dentro de su equipo
var has_taken_turn: bool = false ##Marca si el personaje a comenzado el turno
var ally_team: Array[BaseCharacter] ##Guarda el equipo entero del personaje
var opps_team: Array[BaseCharacter] ##Guarda el equipo entero oponente del personaje
var is_defeated: bool = false

var is_highlighted = false
var normal_modulate = Color(1, 1, 1, 1)
var highlight_modulate = Color(1.2, 1.2, 0.8, 1)
var defeated_modulate = Color(1.2,0.8,1.2,1)


#TODO DEBUG
#func _ready():
	#initialize_character("testDumy", 0,0)
	#highlight(true)

'''
Codigo de inicializacion
'''
##Crea una escena de personaje usando el id del recurso a usar el id para identificarlo en combate
##tambien recibe el id que tiene que tener marcado para indentificarlo en el combate y su posicion inicial
func initialize_character(char_data_id: String, new_id: int, char_pos: int, battle_event_bus: BattleEventBus):
	#Inicializa los nodos hijos
	sprite = get_node("Sprite2D")
	animationPlayer = get_node("AnimationPlayer")
	area2D = get_node("Area2D")
	statusEffects = get_node("StatusEffects")

	event_bus = battle_event_bus
	
	#Llama al repositorio de personajes para cargar sus datos
	var character = CharacterRepo.load_character_data_by_id(char_data_id)
	if character == null:
		print("Character not found")
		return null
	set_character_info(character,new_id, char_pos)
	return true

##Recibe un characterData, un id y la posicion para inicializar las variables del personaje
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

##Recibe los dos equipos y los guarda, el primero siempre es el propio
func set_teams(new_ally_team: Array, new_opps_team: Array):
	ally_team = new_ally_team
	opps_team = new_opps_team
	return true
	
##Se llama desde las clases hija para poner el alineamiento del personaje
func set_alignment(new_alignment: BattleConstants.Alignment):
	alignment = new_alignment

##Debug only	
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
##Saca busca todos los triggers de fase en las habilidades de los personajes
func get_phase_triggered_abilities(phase_trigger: BattleConstants.TriggerPhase):
	var triggered_abilities = []
	for ability in abilities:
		if ability.TriggerPhase == phase_trigger:
			triggered_abilities.append(ability)
	return triggered_abilities

##TODO comprueba que la habilidad se pueda ejecutar, debería comprobar cooldowns, posicion y cosas por el estilo
func can_use_ability(_ability):
	return true

##Si es una habilidad que no se elige objetivo para que se elija de forma automatica
##Por ahora devuelve los personajes a los que hay que afectar
func automatic_targeting(ability):
	var targets = []
	var char_list = []
	var self_targeting = false
	
	# Then check target type
	if ability.TargetType == BattleConstants.TargetType.SELF:
		self_targeting = true
	elif ability.TargetTeam == BattleConstants.TargetTeam.OPPONENT:
		get_opponent_positions()
	elif ability.TargetTeam == BattleConstants.TargetTeam.ALLY:
		get_ally_positions()
	
		
	if !self_targeting:
		for pos in char_list:
			if ability.get_target_positions.has(pos):
				targets.append(char_list[pos])
	else:
		targets.push_front(self)
	
	return targets
	
##Funcion que hace lo que le toque al empezar el turno, siempre se sobreescribe
func start_turn():
	print("start_turn called directly, this function should be overriden")
	print_character_stats()
	return true

##Ejecuta la habilidad sabiendo a quien apunta
func execute_ability(ability: AbilityData, targets: Array [BaseCharacter]):
	event_bus.emit_signal("ability_executed",self, ability, targets)	
	# Activa los efectos en los objetivos, comprueba que no este vacio por si acaso
	if !targets.is_empty():
		for effect in ability.effects:
			effect.execute(self, ability.multiplier, targets)

	else:
		push_error("Error- Targets is empty - This should be imposible")
	
	event_bus.emit_signal("stats_changed")

##Funcion para recibir dano, le llega la cantidad que tiene que recibir y el atacante
##TODO le faltaria triggers y cosas por el estilo
func take_damage(dmg: int, _source):
	current_hp -= dmg
	if current_hp <= 0:
		current_hp = 0
		defeat()
	event_bus.emit_signal("stats_changed")
	event_bus.emit_signal("health_changed", current_hp, max_hp)

# New function to handle character defeat
func defeat():
	if is_defeated:
		return true
	
	is_defeated = true
	print(char_name + " has been defeated!")
	
	# Signal defeat - will be processed by state machine at appropriate time
	event_bus.emit_signal("character_defeated", self)
	return true

##Recibe curacion, recibe la cantidad a curar y el curador
func take_healing(heal, _source):
	current_hp += heal
	if current_hp > max_hp:
		current_hp = max_hp
		
	event_bus.emit_signal("stats_changed")
	event_bus.emit_signal("health_changed", current_hp, max_hp)
	return true

##La usan los personajes para moverse, recibe la posicion incial, la posicion
##a la que tiene que ir y quien lo ha movido
func moving(starting_position, final_position, _source):
	#Corrige que el objetivo no se salga de las posiciones posibles
	if final_position > BattleConstants.max_formation_position:
		final_position = BattleConstants.max_formation_position
	elif final_position < BattleConstants.min_formation_position:
		final_position = BattleConstants.min_formation_position
		
	#TODO pongo que si la posicion inicial y la final son la misma se corta antes de tiempo
		
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
	var allies_positions = get_ally_positions()
	
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
				
	event_bus.emit_signal("stats_changed")
	event_bus.emit_signal("character_moved",self)			
	
##Esta funcion se usa cuando los personajes estan haciendo espacio para otro, tiene menos
##comprobaciones porque la funcion de moverse larga ya se encarga de eso
func moving_correction(step: int):
	self.char_position += step
	
##Funcion que devuelve un array con los aliados en la posicion correcta ordenada
func get_ally_positions():
	#Busca si algun aliado comparte la misma posicion
	var char_list = {} 
	for ally in ally_team:
		char_list.set(ally.char_position, ally)
	return char_list
	
##Funcion que devuelve un array con los enemigos en la posicion correcta ordenada
func get_opponent_positions():
	#Busca si algun aliado comparte la misma posicion
	var char_list = {} 
	for opp in opps_team:
		char_list.set(opp.char_position, opp)
	return char_list

##TODO ni idea de que poner aquí aun
func add_status(_status, _source):
	pass
	
'''
Codigo para feedback visual
'''
func set_formations_manager(manager):
	formations_manager = manager
	print(formations_manager)

func update_position():
	if formations_manager != null:
		global_position = formations_manager.get_new_position(alignment, char_position)

# Highlight function
func highlight(enable: bool):
	is_highlighted = enable
	if enable:
		modulate = highlight_modulate
	else:
		modulate = normal_modulate

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		event_bus.emit_signal("clicked", self)
		get_viewport().set_input_as_handled()  # Prevent event from propagating
