# FormationsManager.gd
extends Node2D
## Gestor de formaciones que maneja el posicionamiento de personajes en equipos.
## Se encarga de calcular las posiciones de los personajes en pantalla basandose en su equipo
## y posicion dentro de la formacion.
class_name FormationsManager

## Centro de la pantalla calculado automaticamente.
var screen_center: Vector2

## Tamano total de la pantalla visible.
var screen_size: Vector2

## Parametros de formacion

## Espaciado entre personajes en pixeles.
var character_spacing = 125

## Distancia desde el centro hasta el primer personaje de cada equipo.
var team_offset_from_center = 0

## Inicializa el gestor calculando el centro y tamano de pantalla.
func _ready():
	var visible_rect = get_viewport().get_visible_rect()
	screen_size = visible_rect.size
	screen_center = visible_rect.position + screen_size / 2

## Devuelve la posicion global para un personaje basado en su equipo y posicion.
## [param team_name] Nombre del equipo ("player" para jugador, otro valor para enemigo).
## [param position_index] Indice de posicion dentro del equipo (1 = primero).
## [return] Posicion Vector2 en coordenadas globales donde debe ubicarse el personaje.
func get_new_position(team_name: String, position_index: int) -> Vector2:
	var base_y = screen_center.y
	
	if team_name == "player":
		# Equipo del jugador en el lado izquierdo
		var x = screen_center.x - team_offset_from_center - (position_index * character_spacing)
		var pos = Vector2(x, base_y)
		return pos
	else:
		# Equipo enemigo en el lado derecho
		var x = screen_center.x + team_offset_from_center + (position_index * character_spacing)
		var pos = Vector2(x, base_y)
		return pos