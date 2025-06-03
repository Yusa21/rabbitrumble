extends Node2D
class_name BaseCharacter
##Clase que representa un personaje involucrado en un combate
##
##Contiene el codigo de iniciciacion del personaje (quizas habria que moverlo a otra parte) y 

@onready var sprite: Sprite2D
@onready var animationPlayer: AnimationPlayer
@onready var area2D: Area2D
@onready var statusEffects: Node2D

##Formations manager para que los personajes puedan aparecer en pantalla en los lugares correctos
var formations_manager = null

const min_position = 1 ##La posicion minima donde pueden estar los personajes
const max_position = 4 ##Igual con la posicion maxima

##Referencia al bus de enventos
var event_bus: BattleEventBus = null

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

var is_highlighted = false ##Controla si un personaje tiene algun highlight
const normal_modulate = Color(1, 1, 1, 1)
const highlight_modulate = Color(1.2, 1.2, 0.8, 1)
const defeated_modulate = Color(1.2, 0.8, 1.2, 1)

'''
Codigo de inicializacion
'''
##Crea una escena de personaje usando el id del recurso a usar el id para identificarlo en combate
##tambien recibe el id que tiene que tener marcado para indentificarlo en el combate y su posicion inicial
##[param char_data_id] Id del char data que se quiere cargar
##[param new_id] Id que se le va asignar al instancia especifica de BaseCharacter
##[param char_pos] Posicion inicial que se le va a asignar al personaje en la formacion
func initialize_character(char_data_id: String, new_id: int, char_pos: int):

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

##Funcion que anade el bus de eventos al personaje
##[param bus] Bus de eventos al que se subscribe el personaje, en este caso el de batalla
func initialize_with_event_bus(bus: BattleEventBus):
	event_bus = bus
	return true

##Recibe un characterData, un id y la posicion para inicializar las variables del personaje
##[param character] Informacion del personaje que se va usar para inicializar
##[param new_id] Id que se le va asignar al instancia especifica de BaseCharacter
##[param char_pos] Posicion inicial que se le va a asignar al personaje en la formacion
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

##Recibe los dos equipos y los asigna al personaje
##[param new_ally_team] Equipo al que pertence el personaje
##[param new_opps_team] Equipo opuesto al que pertence el personaje
func set_teams(new_ally_team: Array, new_opps_team: Array):
	ally_team = new_ally_team
	opps_team = new_opps_team
	return true
	
##Se llama desde las clases hija para poner el alineamiento del personaje
##[param new_alginment] Alineamiento/Equipo al que pertence el personaje 
func set_alignment(new_alignment: String):
	alignment = new_alignment

##Debug solo, escribe las stas del personaje 
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
##[param phase_trigger] Fase del turno actual para saber que habilidades se activan
##[return] Lista de habilidades que se activan en la fase
func get1_phase_triggered_abilities(phase_trigger):
	#Todas la habilidades del personaje que se actvian
	var triggered_abilities = []
	#Busca las habilidades que se activan por fase y que se activan en la fase en concreto
	for ability in abilities:
		if ability.is_phase_triggered and ability.trigger_phase == phase_trigger:
			triggered_abilities.append(ability)
	return triggered_abilities

##Comprueba que la habilidad se pueda ejecutar, debería comprobar cooldowns, posicion y cosas por el estilo
##Por ahora simplemente es positivo siempre
func can_use_ability(_ability):
	return true

##Funcion que elige objetivo de forma automatica para las habilidades
##Por ahora siempre afecta a todos los posibles objetivos
##[param phase_trigger] Hablidad que se esta ejecuntando con seleccion automatica
##[return] Lista de objetivos a los que la habilidad tiene que afectar
func automatic_targeting(ability):
	var targets = []
	var char_list = []
	var self_targeting = false
	
	# Comprueba que tipo de seleccion tiene
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
##[param ability] Abilidad que si tiene que ejecutar
##[param tar] Lista de objetivos
func execute_ability(ability, tar: Array):
	var targets = tar.duplicate()
	# Emita la senal de que habilidad se esta usando
	if event_bus:
		event_bus.emit_signal("ability_used", self, ability, targets)

	#Compruena que animacion se tiene que usar	
	if ability.animation_name == "attack":
		animationPlayer.play("attack")
		#Si la habilidad ataca al equipo enemigo entero emite la senal para que se mueva la pantalla
		if ability.target_position.size() >= 4 and ability.target_type == "multiple_opps":
			await get_tree().create_timer(0.75).timeout
			#Senal de que es una habilidad masiva y que la pantalla de deberia mover
			event_bus.emit_signal("massive_ability_used", self, ability, targets)
			
		await animationPlayer.animation_finished
	else:
		animationPlayer.play("healing")
		await animationPlayer.animation_finished

	
	# Activa los efectos en los objetivos, comprueba que no este vacio por si acaso
	if !targets.is_empty():
		for effect in ability.effects:
			#Ejecuta el efecto y espera que termine
			await effect.execute(self, ability.multiplier, targets)
			
			#Si la habilidad tiene varios efectos notifica cambios para UI y espera para que sea entendible
			if ability.effects.size() >= 2:
				notify_stats_changed()
				await get_tree().create_timer(1).timeout
	else:
		push_error("Error- Targets is empty - This should be imposible")
	
	#Avisa a la UI para que actualice habilidades
	notify_stats_changed()
	return true


##Function para recibir dano
##[param dmg] Cuanto dano tiene que recibir el personaje
##[param attacker] Personaje que esta haciendo dano a este personaje
func take_damage(dmg, _attacker):
	var battle_manager = get_parent().get_parent().get_node("BattleManager")

	if battle_manager != null:
		# Notifica al battle manager de que tiene que tener en cuenta una nueva fuente de dano
		battle_manager.increment_pending_damage()
	else:
		push_error("Error: Battle manager not found in character script")
	
	#Resta el dano a la vida
	current_hp -= dmg
	
	# Animacion de herido
	sprite.play_damage_flash()
	animationPlayer.play("hurt")
	await animationPlayer.animation_finished
	
	# Comprueba si el personaje ha sido derrotado
	if current_hp <= 0:
		current_hp = 0
		defeat()
	else:
		# Si sobrevive lo anuncia por el bus
		if event_bus:
			event_bus.emit_signal("still_alive", self)
   
	notify_stats_changed()
   
	# Notifica que la vida ha cambiado
	if event_bus:
		event_bus.emit_signal("health_changed", self, current_hp, max_hp)

	return true

##Funcion que maneja un personaje derrotado
func defeat():
	#Si el personaje ya esta marcado como derrotado se sale antes
	if is_defeated:
		return true
   
   #Marca el personaje como derrotado
	is_defeated = true
   
	# Modula al highlight de derrotado
	modulate = defeated_modulate
   
	# Avisa que esta derrotado por el bus
	if event_bus:
		event_bus.emit_signal("character_defeated", self)
   
	return true

##Maneja la recuperacion de vida
##[param heal] Cuanta vida tiene que recuperar el personaje
##[param healer] Personaje que esta curando a este personaje
func take_healing(heal, _healer):

	#Animacion de ser curado
	sprite.play_healing_wave()
	animationPlayer.play("healed")
	await animationPlayer.animation_finished

	#Si el personaje esta derrotado no recupera vida
	if !is_defeated:
		current_hp += heal
		if current_hp > max_hp:
			current_hp = max_hp
		
	notify_stats_changed()
	
	if event_bus:
		event_bus.emit_signal("health_changed", self, current_hp, max_hp)
	
	return true

#NO SE USA, PARA FUTURO DESARROLLO
'''
func moving(starting_position, final_position, _mover):
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
'''

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

##Funcion que emite la senal de cambio de estadisticas
func notify_stats_changed():
	if event_bus:
		event_bus.emit_signal("character_stats_changed", self)
	
'''
Codigo para feedback visual
'''
##Asiga el manager de formaciones
##[param manager] Manager de formaciones a asignar
func set_formations_manager(manager):
	formations_manager = manager

##Actualiza la posicion del personaje en la pantalla
func update_position():
	if formations_manager != null:
		#Pide su posicion nueva al manager
		global_position = formations_manager.get_new_position(alignment, char_position)
		
		# Notifica que el personaje se ha movido usando el bus
		if event_bus:
			event_bus.emit_signal("character_moved", self)

## Activa o desactiva el highlight de seleccion desde la UI
##[param enable] Booleano que marca si se tiene que activa o desactivar el highlight
func highlight(enable: bool):
	is_highlighted = enable
	if enable:
		modulate = highlight_modulate
	else:
		modulate = normal_modulate
	
	# Notifica el highlight por el bus
	if event_bus:
		event_bus.emit_signal("character_highlight", self, enable)

##Comprueba si un personaje has sido pulsado
##[param event] Input event que ha sucedido al pulsar al personaje 
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	#Si el evento que ocurre en un click del raton y el area del personaje ha sido pulsada entonces este personaje ha sido clickado 
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Notifica el evento por el bus
		if event_bus:
			event_bus.emit_signal("character_clicked", self)
		get_viewport().set_input_as_handled()  # Marca el input como manejado para que no se propague
