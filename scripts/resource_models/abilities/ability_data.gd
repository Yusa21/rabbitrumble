extends Resource
class_name AbilityData

@export var name: String = "Ability" ##Nombre de la habilidad
@export var description: String = "Description" ##Descripcion de la habilidad

# Target properties
@export var target_team: BattleConstants.TargetTeam = BattleConstants.TargetTeam.OPPONENT
@export var target_type: BattleConstants.TargetType = BattleConstants.TargetType.SINGLE

@export var multiplier: float = 1.0 ##Multiplicador de daño que se aplica al ataque
@export var effects: Array[AbilityEffect] = []  ##Lista de efectos, son como piezas de lego monta y colorea

#Uso bitmasks para las posiciones
@export_flags("Pos 1", "Pos 2", "Pos 3", "Pos 4") var launch_position: int = 15  
@export_flags("Pos 1", "Pos 2", "Pos 3", "Pos 4") var target_position: int = 15

@export var cooldown: int = 0 ##Turnos que hay que esperar para poder volver a repetir la habilidad
@export var icon_sprite: Texture2D = load("res://assets/sprites/abilities/test_ability_icon.png") ##Icono de la habilidad
@export var animation_name: BattleConstants.AnimationName = BattleConstants.AnimationName.ATTACK

# Trigger properties
@export var is_phase_triggered: bool = false
@export var trigger_phase: BattleConstants.TriggerPhase = BattleConstants.TriggerPhase.NONE
@export_flags("Self", "Ally", "Enemy") var trigger_on_turns: int = 0

func get_marked_positions_from_bitmask(bitmask: int) -> Array[int]:
	var marked_positions := []
	var bit_count := 32  # Por ahora 32 sobra

	for i in range(bit_count):
		if bitmask & (1 << i):
			marked_positions.append(i + 1)
	return marked_positions


func get_launch_positions() -> Array[int]:
	return get_marked_positions_from_bitmask(launch_position)

func get_target_positions() -> Array[int]:
	return get_marked_positions_from_bitmask(target_position)

# Helper functions for trigger checks
func can_trigger_on_turn(turn_owner: BattleConstants.TurnOwner) -> bool:
	return (trigger_on_turns & turn_owner) != 0

func can_launch_from_position(position_index: int) -> bool:
	var position_flag = 1 << (position_index - 1)  # Convert position 1-4 to corresponding bit
	return (launch_position & position_flag) != 0
	
func can_target_position(position_index: int) -> bool:
	var position_flag = 1 << (position_index - 1)  # Convert position 1-4 to corresponding bit
	return (target_position & position_flag) != 0
