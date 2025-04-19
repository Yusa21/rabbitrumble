extends Node
##Singleton para las constantes de combate, planteate convertirlo en una clase que se pasa por componentes
##pero por ahora esto funciona

#------------------------------
#PATH A ESCENAS
#------------------------------

const player_char_path = "res://scenes/characters/player/player_character.tscn"
const enemy_char_path = "res://scenes/characters/enemy/enemy_character.tscn"

#------------------------------
#CONSTANTES DE EQUIPOS/FORMACIONES
#------------------------------

#Posiciones maximas y minimas

const min_formation_position = 1
const max_formation_position = 4

#Alineamientos de personajes

enum Alignment{
	PLAYER,
	ENEMY
}

#------------------------------
#CONSTANTES DE FASES DE COMBATE
#------------------------------

#Estado del combate/fases del combate
enum BattleState {
	INIT,
	ROUND_START,
	PRE_TURN,
	MAIN_TURN,
	POST_TURN,
	ROUND_END,
	CHARACTER_DEFEATED,
	BATTLE_END,
	
}

#Triggers que no comprueban de quien es el turno
enum GlobalTriggers {
	BATTLE_START,
	BATTLE_END,
	ROUND_START,
	ROUND_END,
	
}

#Triggers que depende del turno de quien sea el turno
enum TurnTriggers {
	PRE_TURN,
	MAIN_TURN,
	POST_TURN,
	
}

#------------------------------
#CONSTANTES DE HABILIDADES
#------------------------------

enum LaunchPosition{
	POS_1 = 1,
	POS_2 = 2,
	POS_3 = 4,
	POS_4 = 8,
}

enum TargetPosition{
	POS_1 = 1,
	POS_2 = 2,
	POS_3 = 4,
	POS_4 = 8,
}

enum TargetTeam {
	NONE,
	ALLY,
	OPPONENT,
}

enum TargetType{
	SINGLE,
	MULTIPLE,
	SELF,	
}

enum TriggerPhase {
	NONE,
	BATTLE_START,
	BATTLE_END,
	ROUND_START,
	ROUND_END,
	PRE_TURN,
	MAIN_TURN,
	POST_TURN,
}

enum TurnOwner {
	SELF = 1,
	ALLY = 2,
	ENEMY = 4
}

enum AnimationName{
	NONE,
	ATTACK,
	MAGIC_ATTACK,
	DEFENSE
}
