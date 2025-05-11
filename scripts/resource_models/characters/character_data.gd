extends Resource
class_name CharacterData

@export var character_id: String = "0" ##Id del personaje se usa para distinguir las distintas clases
@export var character_name: String = "Character" ##Nombre del personaje
@export var character_description: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean facilisis velit blandit"
@export var max_hp: int = 100 ##Salud maxima de personaje, si llega a 0 para abajo
@export var attack: int = 10 ##Se usa de base para decidir cuanto dano hacen las habilidades
@export var defense: int = 10 ##Reduce el dano recibido
@export var speed: int = 10 ##Decide el orden en que el que se mueven los personajes
@export var character_icon: Texture2D ##Icono para las interfaces
@export var idle_sprite: Texture2D ##Sprite cuando no pasa nada
@export var abilities: Array[AbilityData] = [] ##Todas las habilidades del personaje
