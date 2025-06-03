extends Resource
##Clase modelo que se usa para guardar la informacion de los personajes
class_name CharacterData

@export var character_id: String = "0" ##Id del personaje se usa para distinguir las distintas clases
@export var character_name: String = "Character" ##Nombre del personaje
@export var character_description: String = "Lorem ipsumt" ##Descripcion del personaje
@export var max_hp: int = 100 ##Salud maxima de personaje, si llega a 0 para abajo
@export var attack: int = 10 ##Se usa de base para decidir cuanto dano hacen las habilidades
@export var defense: int = 10 ##Reduce el dano recibido
@export var speed: int = 10 ##Decide el orden en que el que se mueven los personajes
@export var character_icon: Texture2D ##Icono para las interfaces
@export var idle_sprite: Texture2D ##Sprite cuando no pasa nada
@export var abilities: Array[AbilityData] = [] ##Todas las habilidades del personaje

##Se usa para poder comparar el id a la hora de cargar los personaje
func get_id():
    return character_id
