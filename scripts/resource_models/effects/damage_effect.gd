extends AbilityEffect
class_name DamageEffect
##Clase que tiene el execute para hacer dano a uno o multiples objetivos
##
##Recibe el usuario de la habilidad, el mutiplicador de la habilidad y los objetivos
##Calcula el dano a realizar con la siguiente operacion (Atk*2 - Def) * Multiplicador
##Llama al metodo [code]take_damage()[/code] de los objetivos
##Devuelve [code]true[/code] si todo sale bien
func execute(user, multipler, targets):
	
	for target in targets:
		var defense = target.def
		#Formula de ataque provisional, atk * 2 - def, el multiplicador de la habildad es muy importante
		var damage = (user.atk * 2 - target.def) * multipler

		#Para evitar que cure o que no haga nada de daño
		if (damage <= 0):
			damage = 1
		 
		target.take_damage(int(damage), user)
		
	return true
