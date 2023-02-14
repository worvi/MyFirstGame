extends KinematicBody2D

var max_hp: int
var current_hp: int
var team
var ship_type
var is_alive = true
var spended_kapusta: int = 0
var task_number
var task_statistics: Dictionary
var T = ServerData.TASK


func init(_player_id: int, _player_information: Dictionary, _task_number, _task_statistics) -> void:
	name = str(_player_id)
	position = _player_information.Location.P
	rotation = _player_information.Location.R
	max_hp =   _player_information.MaxHP
	current_hp = max_hp
	team =     _player_information.T
	ship_type =_player_information.ST
	task_number = _task_number
	task_statistics = _task_statistics
	set_team_properites(team)

func set_team_properites(team_id: int):
	if team_id == 1:
		add_to_group("Team1")
		set_collision_layer(2)
		set_collision_mask(36)
	elif team_id == 2:
		add_to_group("Team2")
		set_collision_layer(4)
		set_collision_mask(34)
	else:
		print("There is no such grup!")

func set_task(_task_number, _task_statistics):
	if task_number == T.WIN || task_number == T.SELF_DESTRUCTION:
		print("[ServerPlayer] Tried to change '", task_number ,"' task. Player: ", self.name)
		return
	if _task_number == T.SELF_DESTRUCTION:
		var timer = Timer.new()
		timer.name = "SelfDestruction"
		timer.autostart = true
		timer.wait_time = _task_statistics.SELF_DESTRUCTION_TIME
		timer.connect("timeout", self, "die")
		add_child(timer)
		# [info] * 1000 bcs change seconds in miliseconds
		_task_statistics["SelfDestructionAbsTime"] = \
				_task_statistics.SELF_DESTRUCTION_TIME * 1000 + OS.get_ticks_msec()
	task_number = _task_number
	task_statistics = _task_statistics
	get_node("/root/GameServer").send_new_task(int(name), _task_number, _task_statistics)

#DIABLE CHANGING SETTING SELF DESTROYS

func on_hit(damage):
	current_hp -= damage
	if current_hp > 0:
		get_node("/root/GameServer/WorldMap/StateProcessing").player_hp[int(get_name())]["HP"] = current_hp
		return
	die()


func get_all_spawning_informations() -> Dictionary:
	var _player_spawning_informations = {
		"T": team,
		"ST": ship_type,
		"MaxHP" :  max_hp,
		"Location": {
			"P": position,
			"R": rotation
		}
	}
	return _player_spawning_informations

func die():
	current_hp = 0
	if is_alive:
		is_alive = false
		print(name, " died")
		# [improve] Change comunicate for self destruction 
		get_node("/root/GameServer").player_died(int(name), ServerData.DES.DESTROYED)
