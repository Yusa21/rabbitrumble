## Clase auxiliar que almacena el estado de desplazamiento del fondo para que persista entre instancias.
class_name BackgroundState
extends RefCounted

## Posición actual de la primera textura de fondo.
var position1: Vector2 = Vector2.ZERO

## Posición actual de la segunda textura de fondo.
var position2: Vector2 = Vector2.ZERO

## Indica si el estado ya fue inicializado.
var is_initialized: bool = false
