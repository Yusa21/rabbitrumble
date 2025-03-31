extends AbilityEffect
class_name HealingEffect

func execute(user, multipler, targets):
	
	for target in targets:
		var healing = user.atk * multipler
		target.take_healing(int(healing), user)
		
	return true
