extends Node
class_name StageSelectionBus

## Señal emitida cuando el usuario hace clic en una etapa en la lista
## [param stage] La instancia de StageData correspondiente a la etapa seleccionada
@warning_ignore("unused_signal")
signal stage_clicked(stage)

## Señal emitida cuando se presiona el botón de iniciar
@warning_ignore("unused_signal")
signal start_button_clicked()

## Señal emitida cuando se presiona el botón de volver al menú principal
@warning_ignore("unused_signal")
signal back_button_clicked()
