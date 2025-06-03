extends Node
class_name MainMenuBus

## [signal] Emitido cuando se presiona el botón de "Start" en el menú principal.
@warning_ignore("unused_signal")
signal start_button_clicked

## [signal] Emitido cuando se presiona el botón de "Exit" en el menú principal.
@warning_ignore("unused_signal")
signal exit_button_clicked

## [signal] Emitido cuando finaliza la pantalla de introducción de historia (lore dump).
@warning_ignore("unused_signal")
signal fade_out_lore_dump
