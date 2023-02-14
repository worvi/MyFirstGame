extends Node

# despawn reasons
var DES: Array = ["DISCONNECT", "OWN_CHOICE", "DESTROYED", "TERRA_SHIP_DESTROYED"]

# root path
const PLAYER_PATH = "/root/Main/Player"
const KAPUSTA_PATH = "/root/Main/KapustaControlNode"
const TEMPLATES_PATH = "/root/Main/PlayersWorld"


# res path
const PLAYER_TEMPLATE_GD = {	
		"StandardShip": preload("res://Ships/StandardShip_T_.gd"), 
		"ShipWithGun": preload("res://Ships/ShipWithGun_T_.gd"),
		"TerraShip": preload("res://Ships/TerraShip_T_.gd")
}

# tscn path
const ENEMY_SPAWN_TSCN = preload("res://Enemies/BotShip.tscn")
const SHIPS_DICT_TSCN = {	
		"StandardShip": preload("res://Ships/StandardShip.tscn"), 
		"ShipWithGun": preload("res://Ships/ShipWithGun.tscn"),
		"TerraShip": preload("res://Ships/TerraShip.tscn")
}



# Tasks names
var taskS = {
	-1: "Self-destruction",
	0: "Waiting for task",
	1: "Attack",
	2: "Defend",
}
# TASKS
enum TASK {WIN = -69, SELF_DESTRUCTION = -1, WAITING_FOR_ORDERS, ATTACK, DEFEND, CAPUTRE_POINTS}
var task_data #Is fulfield by server
# ------------- Multiples -------------
# [info] with all information
var multipleS: Dictionary setget set_multipleS
# [info] Only terminal values
var terminal_multipleS: Dictionary

# [info] This function is changing arrangement of dictionary
# example:
# {task: {Damage: 1, Acc: 1}}
# into:
# {Damage:	{task: 1}}
# {Acc: 	{task: 1}}
func set_multipleS(data: Dictionary):
	for element in data:
		for statistic in data[element]:
			if !multipleS.has(statistic):
				multipleS[statistic] = {element: data[element][statistic]}
			else:
				multipleS[statistic][element] = data[element][statistic]
				
	# [info] setting terminal output
	for statistic in multipleS:
		var multiple_factor = 1
		for multiple_value in multipleS[statistic].values():
			multiple_factor *= multiple_value
		terminal_multipleS[statistic] =  multiple_factor
	
	# [info] refreshing elements whisch use multipleS
	get_node("/root/Main/GUI/StatsMupltiplierInfo").display_value()
	get_node(LocalData.PLAYER_PATH).set_acceleration_factor()
