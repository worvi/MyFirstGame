extends Node
# [improve] good thing to think: Is it better to send to client at the starting packet the actual state of ServerData???
var skill_data
# [improve] Make this to be sended to client
var weapons_data = {
	"Laser" : {
		"Speed": 2000,
		"Damage" : 25,
		"LifeTime": 3
	}
}
# [improve] Make this to be sended to client
const SHIP_DATA = {
	"StandardShip": {
		"MaxHP": 200,
		"BaseAcceleration": 5,
		"RateOfFire": 0.5
	},
	"ShipWithGun": {
		"MaxHP": 200,
		"BaseAcceleration": 5,
		"RateOfFire": 0.5
	},
	"TerraShip": {
		"MaxHP": 10000,
		"BaseAcceleration": 200,
		"RateOfFire": 0.5
	}
}
const TERRA_SHIP_BEG_KAPUSTA = 100
const MULTIPLIER_INCREMENTOR = 0.25
const COST_OF_UPGRADES = 50
# [info] key is the team number
var multipliers = {
	1: {
		"Damage": 1,
		"Acceleration": 1
	},
	 2: {
		"Damage": 1,
		"Acceleration": 1
	}}


var player_spawn_location = {
	1: {
		"P": Vector2(-3000, -3000), 
		"R": deg2rad(90)
	},
	2: {
		"P": Vector2(3000, 3000), 
		"R": deg2rad(-90)
	}
}
# DESPAWN
# [info] Remember to actualize this information in LocalData at client code!
enum DES {DISCONNECT, OWN_CHOICE, DESTROYED, TERRA_SHIP_DESTROYED}

# TASKS
enum TASK {WIN = -69, SELF_DESTRUCTION = -1, WAITING_FOR_ORDERS, ATTACK, DEFEND, CAPUTRE_POINTS}
# [info] IMPORTANT: ADDING TASK HERE, ADD ALSO IN "Local data" to set display name
var task_data = {
	TASK.WIN:{ #Special task only for terra ships
		"Multipliers":{
			"Damage": 1,
			"Acceleration": 1,
		},
	},
	TASK.SELF_DESTRUCTION: {
		"Multipliers":{
			"Damage": 2,
			"Acceleration": 0,
		},
		"SELF_DESTRUCTION_TIME": 5,
		#Will be overriten
		"SelfDestructionAbsTime": null,
	},
	TASK.WAITING_FOR_ORDERS: { # Waiting for orders
		"Multipliers":{
			"Damage": 0.1,
			"Acceleration": 0.1,
		},
	},
	TASK.ATTACK: { # Attack
		"Multipliers":{
			"Damage": 1.2,
			"Acceleration": 1,
		},
	},
	TASK.DEFEND: { # Defend
		"Multipliers":{
			"Damage": 1,
			"Acceleration": 1.5,
		},
	},
	TASK.CAPUTRE_POINTS: {
		"Multipliers":{
			"Damage": 0.8,
			"Accekeration": 2,
		},
	},
}



#func _ready() -> void:
#	var skill_data_file = File.new()
#	skill_data_file.open("res://Data//SkillData.dat", File.READ)
#	var skill_data_copy = skill_data_file.get_var()
#	skill_data_file.close()
#	skill_data = skill_data_copy["laser_dmg"]
#	print(skill_data)
