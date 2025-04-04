extends Resource
class_name AbilityEffect
##Clase padre para el resto de efectos de habilidades
##
##No se usa solo se sobrescribe en las clases que heredan de esta para mantener continuidad

##Funcion para sobreescribir, nunca se llama
func execute(user, multiplier, targets):
	# No hace nada
	push_error("AbilityEffect.execute() called directly. Override this method.")
	return true
