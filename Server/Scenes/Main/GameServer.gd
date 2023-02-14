extends Node

const DEFALUT_PORT = 42521
const MAX_CLIENTS = 16
const WORLD_MAP_TSCN = preload("res://Scenes/World/WorldMap.tscn")
const SERVER_DATA_TSCN = preload("res://Scenes/Singletons/ServerData.gd")
var network = NetworkedMultiplayerENet.new()
var expected_tokens = []
var player_state_collection = {}
var players_with_true_verification = []
var spawn_index = 0


onready var player_verification_process = $PlayerVerification



func _ready() -> void:
	start_server()
	network.connect("peer_connected", self, "_peer_conected")
	network.connect("peer_disconnected", self, "_peer_disconnected")


func start_server() -> void:
	network.create_server(DEFALUT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(network)
	print("Server started")



func _peer_conected(player_id) -> void:
	print("Player " + str(player_id) + " connected")
	# [TEST] Without athentication
	# player_verification_process.start(player_id)
	players_with_true_verification.append(player_id)

func _peer_disconnected(player_id) -> void:
	print("Player " + str(player_id) + " disconnected")
	player_died(player_id, ServerData.DES.DISCONNECT)
	if self.has_node("WorldMap"):
		$WorldMap.disconnection_in_bidding(player_id)
	# [info]: In case someone disconnected during team selection
	if players_with_true_verification.has(player_id):
		players_with_true_verification.erase(player_id)
		# [improve] it looks stupid but it works, never the less try to find better resolve
		if players_with_true_verification.has(player_id):
			players_with_true_verification.erase(player_id)



remote func fetch_saver_time(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_server_time", OS.get_ticks_msec(), client_time)

remote func determine_latency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	# [improve] Is it possible to check it form world state?
	rpc_id(player_id, "return_latency", client_time)


func _on_TokenExpiration_timeout() -> void:
	var current_time = OS.get_ticks_msec()
	var token_time 
	if expected_tokens == []:
		pass
	else:
		for i in range(expected_tokens.size() -1, -1, -1):
			token_time = int(expected_tokens[i].right(64))
			if current_time - token_time >= 30:
				expected_tokens.remove(i)

func fetch_token(player_id):
	rpc_id(player_id, "fetch_token")

remote func return_token(token):
	var player_id = get_tree().get_rpc_sender_id()
	player_verification_process.verify(player_id, token)

func return_token_verification_result(player_id, result):
	rpc_id(player_id, "return_token_verification_result", result)
	#[improve] What if player dont have corr
	if result == true:
		players_with_true_verification.append(player_id)


remote func recive_player_initialization(initialization_info):
	if self.has_node("WorldMap"):
		var player_id = get_tree().get_rpc_sender_id()
		if players_with_true_verification.has(player_id):
			rpc_id(player_id, "ack_player_initialization", $WorldMap.tab_players_waiting_for_spawn.size())
			players_with_true_verification.erase(player_id)
			$WorldMap.add_waiting_player(player_id, initialization_info)

func send_general_starting_info(player_id, for_new_player_info: Dictionary, ship_information):
	rpc_id(player_id, "recive_general_starting_info", for_new_player_info, ship_information)

func send_new_player_to_spawn(player_id, player_info):
	rpc_id(0, "spawn_new_player", player_id, player_info)

# --------BIDDING AREA-----------
remote func recive_bid(bidding_id, bid_amount: int):
	if self.has_node("WorldMap"):
		var terra_ip = get_tree().get_rpc_sender_id()
		$WorldMap/BiddingArea.new_bid(terra_ip, bidding_id, bid_amount)

func send_bid(player_id, bidding_id, player_info, price, _owner):
	# all terras participating in bidding and players which is already bidding.
	rpc_id(player_id, "recive_bidding", bidding_id, player_info, price, _owner)

# --------UPGRADES AREA-----------
remote func get_upgrade_request(property_name):
	if self.has_node("WorldMap"):
		var terra_ip = get_tree().get_rpc_sender_id()
		$WorldMap/Upgrades.upgrade_from_terraship(terra_ip, property_name)

func send_current_multiplier(player_id, property):
	rpc_id(player_id, "recive_upgrade", property)


# ----------TASKS AREA------------
remote func get_task_for_playerS(playerS_ids, task_number):
	if self.has_node("WorldMap"):
		var terra_id = get_tree().get_rpc_sender_id()
		$WorldMap/Tasks.manage_new_task(terra_id, playerS_ids, task_number)

func send_new_task(player_id, task_number, task_data):
	rpc_id(player_id, "recive_new_task", task_number, task_data)


# ----------CAP AREA------------
func send_cap_state(_name, occuping_team):
	rpc_id(0, "recive_cap_state", OS.get_ticks_msec(), _name, occuping_team)




remote func recive_player_state(player_state):
	if self.has_node("WorldMap"):
		var player_id = get_tree().get_rpc_sender_id()
		$WorldMap.add_player_state_to_collection(player_id, player_state)

remote func recive_player_state_OLD(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	if player_state_collection.has(player_id):
		if player_state_collection[player_id]["T"] < player_state["T"]:
			player_state_collection[player_id] = player_state
	# [improve] if it not in player verification... Is it all right? Why is should be there?
	elif !players_with_true_verification.has(player_id):
		print("GEJ GEJ GEJ")
		player_state_collection[player_id] = player_state

# [improve] Is it okey?? to make unreable_attack reable
# [improve] Maybe send attack to "send_world_state"?
#	Take care about spawn_time in future. Its crucial for PVP games!
#   [improve] its hole for hacker to set position of fired attack as client says. It should by done by checking actual ship project in server player instances!!!
#[improve] check if world_state position/ rotation etc have valude/ porper valuse. In other way it will kick out all players
remote func recive_unreable_attack(shoot_state):
	if self.has_node("WorldMap"):
		var player_id = get_tree().get_rpc_sender_id()
		if $WorldMap.spawn_attack(player_id, shoot_state):
			rpc_unreliable_id(0, "receive_unreable_attack", player_id, shoot_state)


func send_world_state(world_state):
	#[improve] check if world_state position/ rotation etc have valude/ porper valuse. In other way it will kick out all players
	rpc_unreliable_id(0, "recive_world_state", world_state)


remote func own_choice_player_self_death():
	var player_id = get_tree().get_rpc_sender_id()
	player_died(player_id, ServerData.DES.OWN_CHOICE)

func player_died(player_id, communicate):
	if self.has_node("WorldMap"):
		if $WorldMap.despawn_player(player_id):
			player_state_collection.erase(player_id)
			players_with_true_verification.append(player_id)
			rpc_id(0, "despawn_player", player_id, communicate)

func battle_has_ended():
	# [improve] Okey, so maybe smth more universal? Like: I want to reset nodes: WorldMap, ServerDataa => Done.
	# [info] Need to set other script to load again (refresh) ServerData
	$WorldMap/StateProcessing.stop_timer()
	network.close_connection()
	for peer in get_tree().get_network_connected_peers():
		network.disconnect_peer(peer, true)
		print("Connected peer: ", peer)# <-------- WTF IS THAT SHIT
	$WorldMap.queue_free()
	#rpc_id(0, "battle_has_ended")
	ServerData.set_script(preload("res://Scenes/Singletons/LocalData.gd"))
	ServerData.set_script(preload("res://Scenes/Singletons/ServerData.gd"))
	# [info]  queue is to slow and withot "remove" adding node is with "2" number at the end
	#$WorldMap.set_physics_process(false)
	# [info] Just to prevent from bugging, when someon is with physical interaction
	players_with_true_verification.clear()
	player_state_collection.clear()
	yield($WorldMap, "tree_exited")
	var world_map_node = WORLD_MAP_TSCN.instance()
	add_child(world_map_node, true)
	start_server()
