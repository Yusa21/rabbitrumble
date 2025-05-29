extends AbilityEffect
class_name HealingEffect
##Clase que tiene el execute para curar a uno o multiples objetivos
##
##Recibe el usuario de la habilidad, el mutiplicador de la habilidad y los objetivos
##Calcula el dano a realizar con la siguiente operacion Atk * Multiplicador
##Llama al metodo [code]take_healing()[/code] de los objetivos
##Devuelve [code]true[/code] si todo sale bien
func execute(user, multipler, targets):
	
	for target in targets:
		var healing = user.atk * multipler #Se usa el ataque para curar
		target.take_healing(int(healing), user)
		print("-------------------Target has " + str(target.current_hp) + " a has healed " + str(healing))
		
	return true
