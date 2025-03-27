extends Resource
#Se usa como clase padre para otros efectos
class_name AbilityEffect

func execute(user, multiplier, targets):
	# No hace nada
	push_error("AbilityEffect.execute() called directly. Override this method.")
	return true
