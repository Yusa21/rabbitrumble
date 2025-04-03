extends AbilityEffect
class_name HealingEffect

func execute(user, multipler, targets):
	
	for target in targets:
		var healing = user.atk * multipler #Se usa el ataque para curar
		target.take_healing(int(healing), user)
		
	return true
