extends Node

var laser = preload("./ServerLaser.tscn")
var enemy_spawn = preload("./ServerBotShip.tscn")

var playerS_state_collection_time_only = {}
var playerS_state_collection = {}
var terra_ship_information = {}
var team_leader_info = {}
var needed_terra_ship_team: Array = [1, 2]
# This is in msec
var begining_time_of_battle: int = 0 setget set_begining_time_of_battle 
var tab_players_waiting_for_spawn: Array = []

var TASK = ServerData.TASK

onready var PlayersNode = $PlayersNode
onready var ships_dict_tscn = {
	"StandardShip": preload("./Ships/StandardShip.tscn"),
	"ShipWithGun": preload("./Ships/ShipWithGun.tscn"),
	"TerraShip": preload("./Ships/TerraShip.tscn"),
}

func _physics_process(_delta: float) -> void:
	if !playerS_state_collection.empty():
		for player_id in playerS_state_collection:
			if has_node("PlayersNode/" + str(player_id)):
				get_node("PlayersNode/" + str(player_id)).position = playerS_state_collection[player_id].Location.P
				get_node("PlayersNode/" + str(player_id)).rotation = playerS_state_collection[player_id].Location.R[0]


func set_begining_time_of_battle(time):
	begining_time_of_battle = time
	get_node("KapustaControlNode").begining_time_of_battle = int(time * 0.001)


func add_player_state_to_collection(player_id, player_state):
	if !playerS_state_collection_time_only.has(player_id):
		return
	if playerS_state_collection_time_only[player_id] < player_state["T"]:
		playerS_state_collection_time_only[player_id] = player_state["T"]
		player_state.erase("T")
		playerS_state_collection[player_id] = player_state

#start timer

func spawn_attack(player_id, shoots_state) -> bool:
	if !PlayersNode.has_node(str(player_id)):
		return false
	for shoot_state in shoots_state.values()[0]:
		var laser_instance = laser.instance()
		laser_instance.init(
				player_id, 
				get_node("PlayersNode/" + str(player_id)).team, 
				get_node("PlayersNode/" + str(player_id)).task_statistics.Multipliers["Damage"], shoot_state)
		# [improve] Add child to "map"
		add_child(laser_instance)
	return true



func add_waiting_player(player_id, initialization_info):
	# [info] Its possible that server is opened shorter than client
	playerS_state_collection_time_only[player_id] = -INF
	if needed_terra_ship_team.size() != 0:
		# [info] creating first info in dictionary, to be able to collect other
		terra_ship_initialization(player_id)
	else:
		initialization_info["ID"] = player_id
		tab_players_waiting_for_spawn.append(initialization_info)
		if tab_players_waiting_for_spawn.size() == 1:
			$BiddingArea.begin_bidding(tab_players_waiting_for_spawn.front(), terra_ship_information.keys())

func initalizate_player_from_auction(wined_terraship_id, beg_kapusta):
	var player_info = tab_players_waiting_for_spawn.pop_front()
	player_info["T"] = terra_ship_information[wined_terraship_id].T
	player_initialization(player_info.ID, player_info, beg_kapusta)
	send_new_player_on_auction()

func send_new_player_on_auction():
	yield(get_tree().create_timer(1.0), "timeout")
	if tab_players_waiting_for_spawn.size() != 0:
		$BiddingArea.begin_bidding(tab_players_waiting_for_spawn.front(), terra_ship_information.keys())

func disconnection_in_bidding(player_id):
	for i in range(tab_players_waiting_for_spawn.size()):
		if player_id == tab_players_waiting_for_spawn[i].ID:
			tab_players_waiting_for_spawn.pop_at(i)
			if i == 0:
				$BiddingArea.bidding_player_disconnected(player_id)
				send_new_player_on_auction()
			break


func terra_ship_initialization(player_id):
	if needed_terra_ship_team.size() == 2:
		create_terra_ship_template(player_id)
	elif needed_terra_ship_team.size() == 1:
		# Clears table because player may send date after battle has ended
		print("Battle has begun")
		$StateProcessing.start_timer()
		create_terra_ship_template(player_id)
		set_begining_time_of_battle(OS.get_ticks_msec())
		spawn_terra_ships()
	else:
		print("[Other terra_ship] This is not gonna happen!")

func create_terra_ship_template(player_id):
	var team = needed_terra_ship_team.pop_front()
	team_leader_info[team] = player_id
	terra_ship_information[player_id] = creating_player_packed_information(
			team, "TerraShip", ServerData.player_spawn_location[team])

func player_initialization(player_id, initialization_info, beg_kapusta):
	var terra_ship_location = get_node("PlayersNode/" + str(team_leader_info[initialization_info.T])).get_all_spawning_informations().Location
	var _player_information = creating_player_packed_information(
			initialization_info.T, initialization_info.ST, terra_ship_location)
	var current_players_info: Dictionary = {}
	for Player in PlayersNode.get_children():
		current_players_info[int(Player.name)] = Player.get_all_spawning_informations()
	spawn_player(player_id, _player_information, 0, $Tasks.task_data[TASK.WAITING_FOR_ORDERS])
	formating_sending_packets(player_id, beg_kapusta, _player_information, current_players_info, 0)
	get_node("/root/GameServer").send_new_player_to_spawn(player_id, _player_information)

func creating_player_packed_information(team, ship_type, location) -> Dictionary:
	var _player_information = ServerData.SHIP_DATA[ship_type].duplicate(true)
	_player_information["T"] = team
	_player_information["ST"] = ship_type
	_player_information["Location"] = location
	return _player_information

func spawn_terra_ships():
	for player_id in terra_ship_information:
		spawn_player(player_id, terra_ship_information[player_id], TASK.WIN,$Tasks.task_data[TASK.WIN])
		# [improve] Better way for non sending self in "other_terra_shipS"?
		var other_terra_shipS = terra_ship_information.duplicate(true)
		other_terra_shipS.erase(player_id)
		formating_sending_packets(player_id, ServerData.TERRA_SHIP_BEG_KAPUSTA,terra_ship_information[player_id], other_terra_shipS, TASK.WIN)

func formating_sending_packets(player_id, beg_kapusta, ship_information, other_playerS_information, init_task):
	var for_new_player_info = {
		"PInfo": other_playerS_information,
		"BT": begining_time_of_battle,
		"BegKapusta": beg_kapusta,
		"UpgradeMultipleS": ServerData.multipliers[ship_information.T],
		"CapturePointsData": $Map.get_all_capture_points_data(),
		"TaskMultipleS": $Tasks.task_data[init_task]
	}
	$StateProcessing.player_hp[player_id] = {"HP" :  ship_information.MaxHP}
	$KapustaControlNode.add_recived_kapusta(player_id, beg_kapusta)
	get_node("/root/GameServer").send_general_starting_info(player_id, for_new_player_info, ship_information)


func spawn_player(player_id, p_info, _task_number, _task_statistics):
	var player_instance = ships_dict_tscn[p_info.ST].instance()
	player_instance.init(player_id, p_info, _task_number, _task_statistics)
	PlayersNode.add_child(player_instance, true)


func despawn_player(player_id) -> bool:
	if !PlayersNode.has_node(str(player_id)):
		return false
	if terra_ship_information.has(player_id):
		despawning_if_terra_ship(player_id, PlayersNode.get_node(str(player_id)).team)
		return false
	playerS_state_collection.erase(player_id)
	playerS_state_collection_time_only.erase(player_id)
	print("Erased: ", player_id)
	PlayersNode.get_node(str(player_id)).queue_free()
	return true

func despawning_if_terra_ship(player_id, terra_ship_team):
	print("Battle has ended")
	# [info] Players waiting for spawning allowed to choice new ship
#	for player in tab_players_waiting_for_spawn:
#		get_parent().players_with_true_verification.append(player.ID)
#	for player_node in $PlayersNode.get_children():
#		get_parent().players_with_true_verification.append(int(player_node.name))
#		player_node.queue_free()
	get_node("/root/GameServer").battle_has_ended()
