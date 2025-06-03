extends Resource
##Clase modelo que se usa para guardar la informacion de las habilidades
class_name AbilityData

@export var name: String = "Ability" ##Nombre de la habilidad
@export var description: String = "Description" ##Descripcion de la habilidad
@export var target_type: String = "single_opp"  ## single_opps, multiple_opps, single_ally, multiple_allies, self
@export var multiplier: float = 1.0 ## Multuplicador de dano que se aplica al ataque
@export var effects: Array [AbilityEffect] = []  ## Lista de efectos de la habilidad
@export var launch_position: Array[int] = [1,2,3,4] ##Posiciones en la sque se puede realizar el ataque
@export var target_position: Array[int] = [1,2,3,4] ##Posiciones a las que puede apuntar el ataque
@export var cooldown: int =  0 ##Turnos que hay que esperar para poder volver a repetir la habilidad, sin usar
@export var icon_sprite: Texture2D = load("res://assets/sprites/abilities/test_ability_icon.png") ##Icono de la habilidad
@export var icon_pressed: Texture2D ##Icono de la habilidad pulsado
@export var icon_disabled: Texture2D ##Icono de la habilidad deshabilitado
@export var animation_name: String = "attack"  ##Por ahora no tengo ni idea de como hacer animaciones pero aqui esta
@export var is_phase_triggered: bool = false ##Marca si las habilidad se activa en alguna fase en concreto os es solo manual
@export var trigger_phase: String = ""  ##Fase en la que la habilidad se activa
@export var trigger_on_self_turn: bool = false  ## Si la habilidad se activa en un turno, esto marca si se activa en turno propio
@export var trigger_on_ally_turn: bool = false  ## Lo mismo con turno de aliados
@export var trigger_on_enemy_turn: bool = false ## Lo mismo con turno de oponentes
