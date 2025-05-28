extends AbilityEffect
class_name DamageEffectRandom
##Clase que tiene el execute para hacer dano a uno o multiples objetivos
##
##Recibe el usuario de la habilidad, el mutiplicador de la habilidad y los objetivos
##Calcula el dano a realizar con la siguiente operacion (Atk*2 - Def) * Multiplicador
##Llama al metodo [code]take_damage()[/code] de los objetivos
##Devuelve [code]true[/code] si todo sale bien
func execute(user, multipler, targets):
    # Check if there are any targets available
    if targets.size() == 0:
        return false
    
    # Select a random target from the targets array
    var random_target = targets[randi() % targets.size()]
    
    var defense = random_target.def
    # Formula de ataque provisional, atk * 2 - def, el multiplicador de la habildad es muy importante
    var damage = ((user.atk * 2 - random_target.def)) * multipler
    random_target.take_damage(int(damage), user)
    
    return true