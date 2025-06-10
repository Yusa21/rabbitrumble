extends Node
class_name CharacterSelectionBus

## Senal emitida cuando se selecciona un personaje.
## [param character] El personaje seleccionado.
@warning_ignore("unused_signal")
signal character_clicked(character)

## Senal emitida cuando se selecciona un personaje enemigo.
## [param character] El personaje enemigo seleccionado.
@warning_ignore("unused_signal")
signal enemy_character_clicked(character)

## Senal emitida cuando se hace click derecho en un personaje.
## [param character] El personaje que recibio el click derecho.
@warning_ignore("unused_signal")
signal character_right_clicked(character)

## Senal emitida cuando se agrega un personaje al equipo.
## [param character_id] ID del personaje agregado.
@warning_ignore("unused_signal")
signal character_added_to_team(character_id)

## Senal emitida cuando se remueve un personaje del equipo.
## [param character_id] ID del personaje removido.
@warning_ignore("unused_signal")
signal character_removed_from_team(character_id)

## Senal emitida cuando se selecciona una habilidad.
## [param ability] La habilidad seleccionada.
@warning_ignore("unused_signal")
signal ability_clicked(ability)

## Senal emitida cuando se presiona el boton de limpiar seleccion.
@warning_ignore("unused_signal")
signal clear_button_clicked

## Senal emitida cuando se presiona el boton de iniciar juego.
@warning_ignore("unused_signal")
signal start_button_clicked

## Senal emitida cuando se presiona el boton de volver atras.
@warning_ignore("unused_signal")
signal back_button_clicked
