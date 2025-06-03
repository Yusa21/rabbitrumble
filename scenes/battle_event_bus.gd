## Sistema de eventos centralizado para la gestion de batallas.
## Maneja todas las senales relacionadas con el flujo de batalla,
## interfaz de usuario, gestion de turnos y estados de personajes.
extends Resource
class_name BattleEventBus

## Senales de interfaz de usuario

## Emitida cuando la interfaz de usuario ha sido inicializada completamente.
@warning_ignore("unused_signal")
signal ui_initialized()

## Emitida cuando el jugador decide rendirse en la batalla.
@warning_ignore("unused_signal")
signal giving_up()

## Emitida cuando la pantalla de fin de batalla ha terminado de mostrarse.
@warning_ignore("unused_signal")
signal end_screen_over

## Senales de flujo de batalla

## Emitida al inicio de una nueva batalla.
@warning_ignore("unused_signal")
signal battle_start

## Emitida al finalizar la batalla.
## [param winner] El participante que gano la batalla.
@warning_ignore("unused_signal")
signal battle_end(winner)

## Emitida al comenzar una nueva ronda.
@warning_ignore("unused_signal")
signal round_start

## Emitida al finalizar la ronda actual.
@warning_ignore("unused_signal")
signal round_end

## Senales de gestion de turnos

## Emitida antes de que comience el turno de un participante.
## [param participant] El participante cuyo turno esta por comenzar.
@warning_ignore("unused_signal")
signal pre_turn(participant)

## Emitida durante el turno principal de un participante.
## [param participant] El participante que esta en su turno principal.
@warning_ignore("unused_signal")
signal main_turn(participant)

## Emitida despues de que termine el turno de un participante.
## [param participant] El participante cuyo turno acaba de terminar.
@warning_ignore("unused_signal")
signal post_turn(participant)

## Gestion de estados

## Emitida cuando el estado del juego cambia.
## [param from_state] El estado anterior.
## [param to_state] El nuevo estado.
@warning_ignore("unused_signal")
signal state_changed(from_state, to_state)

## Senales de estado de personajes

## Emitida cuando un personaje es derrotado.
## [param character] El personaje que fue derrotado.
@warning_ignore("unused_signal")
signal character_defeated(character)

## Emitida para confirmar que un personaje sigue vivo.
## [param character] El personaje que permanece vivo.
@warning_ignore("unused_signal")
signal still_alive(character)

## Emitida cuando la salud de un personaje cambia.
## [param character] El personaje cuya salud cambio.
## [param old_health] El valor anterior de salud.
## [param new_health] El nuevo valor de salud.
@warning_ignore("unused_signal")
signal health_changed(character, old_health, new_health)

## Emitida cuando un personaje usa una habilidad.
## [param character] El personaje que uso la habilidad.
## [param ability] La habilidad utilizada.
## [param targets] Los objetivos de la habilidad.
@warning_ignore("unused_signal")
signal ability_used(character, ability, targets)

## Emitida cuando un personaje usa una habilidad masiva.
## [param character] El personaje que uso la habilidad masiva.
## [param ability] La habilidad masiva utilizada.
## [param targets] Los objetivos de la habilidad masiva.
@warning_ignore("unused_signal")
signal massive_ability_used(character, ability, targets)

## Emitida cuando las estadisticas de un personaje cambian.
## [param character] El personaje cuyas estadisticas cambiaron.
@warning_ignore("unused_signal")
signal character_stats_changed(character)

## Emitida cuando se hace clic en un personaje.
## [param character] El personaje en el que se hizo clic.
@warning_ignore("unused_signal")
signal character_clicked(character)

## Emitida cuando un personaje se mueve.
## [param character] El personaje que se movio.
@warning_ignore("unused_signal")
signal character_moved(character)

## Emitida cuando la posicion de un personaje cambia.
## [param character] El personaje cuya posicion cambio.
@warning_ignore("unused_signal")
signal character_position_changed(character)

## Senales de efectos de estado

## Emitida cuando se aplica un efecto de estado a un personaje.
## [param character] El personaje al que se aplico el efecto.
## [param effect] El efecto de estado aplicado.
@warning_ignore("unused_signal")
signal status_effect_applied(character, effect)

## Emitida cuando se remueve un efecto de estado de un personaje.
## [param character] El personaje del que se removio el efecto.
## [param effect_id] El identificador del efecto removido.
@warning_ignore("unused_signal")
signal status_effect_removed(character, effect_id)

## Senales de resaltado de personajes

## Emitida para controlar el resaltado visual de un personaje.
## [param character] El personaje a resaltar o dejar de resaltar.
## [param enable] True para activar el resaltado, false para desactivarlo.
@warning_ignore("unused_signal")
signal character_highlight(character, enable)

## Senales de interfaz de habilidades

## Emitida cuando se selecciona una habilidad en la interfaz.
## [param ability_data] Los datos de la habilidad seleccionada.
## [param ability_index] El indice de la habilidad en la lista.
@warning_ignore("unused_signal")
signal ability_selected(ability_data, ability_index)

## Emitida cuando se ejecuta una habilidad.
## [param ability_data] Los datos de la habilidad ejecutada.
## [param targets] Los objetivos de la habilidad.
@warning_ignore("unused_signal")
signal ability_executed(ability_data, targets)

## Emitida cuando un personaje pasa su turno.
## [param character] El personaje que paso su turno.
@warning_ignore("unused_signal")
signal turn_passed(character)

## Emitida cuando todo el dano ha sido resuelto.
@warning_ignore("unused_signal")
signal all_damage_resolved