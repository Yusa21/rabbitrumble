extends AbilityEffect
class_name HealingEffectLowest
##Clase que tiene el execute para curar a uno o multiples objetivos
##
##Recibe el usuario de la habilidad, el mutiplicador de la habilidad y los objetivos
##Calcula el dano a realizar con la siguiente operacion Atk * Multiplicador
##Llama al metodo [code]take_healing()[/code] de los objetivos
##Devuelve [code]true[/code] si todo sale bien
func execute(user, multipler, targets):
	var lowest_health_target = targets[0]

	for target in targets:
		if target.current_hp < lowest_health_target.current_hp:
			lowest_health_target = target
	print("Lowest health target is " + str(lowest_health_target))
	var healing = user.atk * multipler #Se usa el ataque para curar
	lowest_health_target.take_healing(int(healing), user)
		
	return true
