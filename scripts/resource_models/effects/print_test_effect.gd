extends AbilityEffect
class_name PrintTestEffect

func execute(user, ability, targets):
	for target in targets:
		print(target.position)
	return true
