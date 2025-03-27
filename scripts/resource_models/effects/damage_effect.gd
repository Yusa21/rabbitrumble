extends AbilityEffect
class_name DamageEffect

func execute(user, multipler, targets):
	
	for target in targets:
		var defense = target.def
		#Formula de ataque provisional, atk * 2 - def, el multiplicador de la habildad es muy importante
		var damage = (user.atk * 2 - target.def) * multipler
		target.take_damage(int(damage), user)
		
	return true
