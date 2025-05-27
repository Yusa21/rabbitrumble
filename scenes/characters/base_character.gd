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

const min_position = 1 ##La posicion minima donde pueden estar los personajes siempre es la misma, para eviat numeros magicos
const max_position = 4 ##Igual con la posicion maxima

# Event bus reference
var event_bus: BattleEventBus = null

#Estadisiticas que luego se cargan
var id ##Id de la INSTANCIA especifica de personaje
var alignment ##A que equipo pertenece el personaje, se le da valor en las subclases
var char_name ##Nombre del personaje
var character_icon ##Icono del personaje, no se usa directamente pero sirve de referencia de otros elementos
var max_hp ##Salud maxima
var current_hp ##Salud actual
var atk ##Ataque del personaje
var def ##Defensa del personaje
var speed ##Velocidad del personaje
var abilities = [] ## Habilidades que el personaje tiene disponibles
var char_position ##Posicion que ocupa el personaje dentro de su equipo
var has_taken_turn: bool = false ##Marca si el personaje a comenzado el turno
var ally_team = [] ##Guarda el equipo entero del personaje
var opps_team = [] ##Guarda el equipo entero oponente del personaje
var is_defeated: bool = false

var is_highlighted = false
var normal_modulate = Color(1, 1, 1, 1)
var highlight_modulate = Color(1.2, 1.2, 0.8, 1)
var defeated_modulate = Color(1.2, 0.8, 1.2, 1)

'''
Codigo de inicializacion
'''
##Crea una escena de personaje usando el id del recurso a usar el id para identificarlo en combate
##tambien recibe el id que tiene que tener marcado para indentificarlo en el combate y su posicion inicial
func initialize_character(char_data_id: String, new_id: int, char_pos: int):
	#Inicializa los nodos hijos
	sprite = get_node("Sprite2D")
	animationPlayer = get_node("Sprite2D/AnimationPlayer")
	area2D = get_node("Area2D")
	statusEffects = get_node("StatusEffects")
	
	#Llama al repositorio de personajes para cargar sus datos
	var character = CharacterRepo.load_character_data_by_id(char_data_id)
	if character == null:
		push_error("Character not found")
		return null
	set_character_info(character, new_id, char_pos)
	return true

# Initialize character with the event bus
func initialize_with_event_bus(bus: BattleEventBus):
	event_bus = bus
	# Connect area input event directly here
	return true

##Recibe un characterData, un id y la posicion para inicializar las variables del personaje
func set_character_info(character: CharacterData, new_id: int, char_pos: int):
	id = new_id
	char_name = character.character_name
	character_icon = character.character_icon
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
func set_alignment(new_alignment: String):
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
func get_phase_triggered_abilities(phase_trigger):
	var triggered_abilities = []
	for ability in abilities:
		if ability.is_phase_triggered and ability.trigger_phase == phase_trigger:
			triggered_abilities.append(ability)
	return triggered_abilities

##TODO comprueba que la habilidad se pueda ejecutar, debería comprobar cooldowns, posicion y cosas por el estilo
func can_use_ability(ability):
	return true

##Si es una habilidad que no se elige objetivo para que se elija de forma automatica
##Por ahora devuelve los personajes a los que hay que afectar
func automatic_targeting(ability):
	var targets = []
	var char_list = []
	var self_targeting = false
	
	# Then check target type
	if ability.target_type.ends_with("opp"):
		get_opponent_positions()
	elif ability.target_type.ends_with("ally"):
		get_ally_positions()
	elif ability.target_type == "self":
		self_targeting = true
		
	if !self_targeting:
		for pos in char_list:
			if ability.target_position.has(pos):
				targets.append(char_list[pos])
	else:
		targets.push_front(self)
	
	return targets
	
##Funcion que hace lo que le toque al empezar el turno, siempre se sobreescribe
func start_turn():
	push_error("start_turn called directly, this function should be overriden")
	print_character_stats()
	return true

##Ejecuta la habilidad sabiendo a quien apunta
func execute_ability(ability, tar: Array):
	var targets = tar.duplicate()
	# Emit ability used event through bus
	if event_bus:
		event_bus.emit_signal("ability_used", self, ability, targets)

	print("Playing attack animation for character with id", id)
	if ability.animation_name == "attack":
		animationPlayer.play("attack")
		await animationPlayer.animation_finished
	else:
		animationPlayer.play("healing")
		await animationPlayer.animation_finished

	
	# Activa los efectos en los objetivos, comprueba que no este vacio por si acaso
	if !targets.is_empty():
		for effect in ability.effects:
			await effect.execute(self, ability.multiplier, targets)
			
			if ability.effects.size() >= 2:
				print("DOING ONE EFFECT----------------------------------")
				notify_stats_changed()
				await get_tree().create_timer(1).timeout

		
		if targets.size() > 0:
			var target_type = "Self" if targets[0] == self else ("Ally" if targets[0] in ally_team else "Enemy")
	else:
		push_error("Error- Targets is empty - This should be imposible")
	
	notify_stats_changed()
	return true


##Function to take damage, gets the amount to receive and the attacker
func take_damage(dmg, attacker):
	print (str(char_name) + " is about to recieve " + str(dmg) + " damage")
	# Notify battle manager to increment pending damage responses
	var battle_manager = get_parent().get_parent().get_node("BattleManager")

	if battle_manager != null:
		battle_manager.increment_pending_damage()
	else:
		push_error("Error: Battle manager not found in character script")
	
	var old_hp = current_hp
	current_hp -= dmg
	
	# Play hurt animation and wait for it to finish
	sprite.play_damage_flash()
	animationPlayer.play("hurt")
	await animationPlayer.animation_finished
	
	# Check if character is defeated
	if current_hp <= 0:
		current_hp = 0
		defeat()
	else:
		# Character survived the attack
		if event_bus:
			event_bus.emit_signal("still_alive", self)
   
	notify_stats_changed()
   
	# Notify health changed through bus
	if event_bus:
		event_bus.emit_signal("health_changed", self, current_hp, max_hp)

	print("-------------------" + str(char_name) + "has " + str(current_hp)) 
	
	return true

# Function to handle character defeat
func defeat():
	if is_defeated:
		return true
   
	is_defeated = true
	print(char_name + " has been defeated!")
   
	# Visual indication
	modulate = defeated_modulate
   
	# Signal defeat through the event bus
	if event_bus:
		event_bus.emit_signal("character_defeated", self)
   
	return true

##Recibe curacion, recibe la cantidad a curar y el curador
func take_healing(heal, healer):

	var old_hp = current_hp
	sprite.play_healing_wave()
	animationPlayer.play("healed")
	await animationPlayer.animation_finished

	if !is_defeated:
		current_hp += heal
		if current_hp > max_hp:
			current_hp = max_hp
		
	notify_stats_changed()
	
	# Notify health changed through bus
	if event_bus:
		event_bus.emit_signal("health_changed", self, current_hp, max_hp)
	
	return true

##La usan los personajes para moverse, recibe la posicion incial, la posicion
##a la que tiene que ir y quien lo ha movido
func moving(starting_position, final_position, mover):
	#Corrige que el objetivo no se salga de las posiciones posibles
	if final_position > max_position:
		final_position = max_position
	elif final_position < min_position:
		final_position = min_position
		
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
	
	# Notify position changed through bus
	if event_bus:
		event_bus.emit_signal("character_position_changed", self)
		event_bus.emit_signal("character_moved", self)
	
	notify_stats_changed()
	return true
	
##Esta funcion se usa cuando los personajes estan haciendo espacio para otro, tiene menos
##comprobaciones porque la funcion de moverse larga ya se encarga de eso
func moving_correction(step: int):
	self.char_position += step
	return true
	
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
func add_status(status, dealer):
	# Notify status effect applied through bus
	if event_bus:
		event_bus.emit_signal("status_effect_applied", self, status)
	return true

# Helper function to notify stats changed
func notify_stats_changed():
	if event_bus:
		event_bus.emit_signal("character_stats_changed", self)
	
'''
Codigo para feedback visual
'''
func set_formations_manager(manager):
	formations_manager = manager

func update_position():
	if formations_manager != null:
		global_position = formations_manager.get_new_position(alignment, char_position)
		
		# Notify character moved through bus
		if event_bus:
			event_bus.emit_signal("character_moved", self)

# Highlight function
func highlight(enable: bool):
	is_highlighted = enable
	if enable:
		modulate = highlight_modulate
	else:
		modulate = normal_modulate
	
	# Notify highlight status through bus
	if event_bus:
		event_bus.emit_signal("character_highlight", self, enable)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Notify character clicked through bus
		if event_bus:
			event_bus.emit_signal("character_clicked", self)
		get_viewport().set_input_as_handled()  # Prevent event from propagating
