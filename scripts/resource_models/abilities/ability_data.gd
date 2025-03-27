extends Resource
class_name AbilityData

@export var name: String = "Ability" #Nombre de la habilidad
@export var description: String = "Description" #Descripcion de la habilidad
@export var target_type: String = "single_enemy"  # single_enemy, multiple_enemies, single_ally, multiple_allies, self
@export var damge_multiplier: float = 1.0 #Multuplicador de dano que se aplica al ataque
@export var effects: Array[Resource] = []  # Lista de efectos TODO pregunta como implementar esto
@export var launch_position: Array[int] = [1,2,3,4] #Posiciones en la sque se puede realizar el ataque
@export var target_position: Array[int] = [1,2,3,4] #Posiciones a las que puede apuntar el ataque
@export var cooldown: int =  0 #Turnos que hay que esperar para poder volver a repetir la habilidad
@export var icon_sprite: Texture2D = load("res://assets/sprites/abilities/test_ability_icon.png") #Icono de la habilidad
@export var animation_name: String = "attack"  #Por ahora no tengo ni idea de como hacer animaciones pero aqui esta
