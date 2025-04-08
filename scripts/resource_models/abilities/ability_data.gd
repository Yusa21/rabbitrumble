extends Resource
class_name AbilityData

@export var name: String = "Ability" ##Nombre de la habilidad
@export var description: String = "Description" ##Descripcion de la habilidad
@export var target_type: String = "single_opp"  ## single_opps, multiple_opps, single_ally, multiple_allies, self
@export var multiplier: float = 1.0 ## Multuplicador de dano que se aplica al ataque
@export var effects: Array [AbilityEffect] = []  ## Lista de efectos, son como piezas de lego monta y colorea
@export var launch_position: Array[int] = [1,2,3,4] ##Posiciones en la sque se puede realizar el ataque
@export var target_position: Array[int] = [1,2,3,4] ##Posiciones a las que puede apuntar el ataque
@export var cooldown: int =  0 ##3Turnos que hay que esperar para poder volver a repetir la habilidad
@export var icon_sprite: Texture2D = load("res://assets/sprites/abilities/test_ability_icon.png") ##Icono de la habilidad
@export var animation_name: String = "attack"  ##Por ahora no tengo ni idea de como hacer animaciones pero aqui esta
@export var is_phase_triggered: bool = false
@export var trigger_phase: String = ""  # pre_turn, turn_start, turn_end, etc.
@export var trigger_on_self_turn: bool = false  # Only relevant for turn-related triggers
@export var trigger_on_ally_turn: bool = false  # Only relevant for turn-related triggers
@export var trigger_on_enemy_turn: bool = false # Only relevant for turn-related triggers
