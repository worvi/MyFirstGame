extends Node

var network = NetworkedMultiplayerENet.new()
#var ip = "127.0.0.1" # FOR PERSONAL USE
#var ip = "10.10.10.50" # FOR EXTERNAL USE
#var ip = "10.8.0.10" # FOR EXTERNAL USE
#var ip = "192.168.0.100" # FOR LOCAL USE
var ip = "194.187.72.136" # FOR EXTERNAL USE
var port = 42521
var token

var server_clock = 0
var latency = 0
var latency_array = []
var sys_time_diff_array = []
var sys_time_diff = 0

const INTERPOLATION_OFFSET = 100
var client_clock = server_clock - INTERPOLATION_OFFSET

var time_diff_make_counter = 0

var is_player_ready = false

var main_tscn = preload("res://Main/Main.tscn")
onready var Main = get_node("/root/Main")

func _ready():
	#network.create_client(ip, port)
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("server_disconnected", self, "_server_disconnected")


func _physics_process(_delta: float) -> void:
	# [buggy] strange ship litlle move foward and backward - is it cloack?
	server_clock = OS.get_ticks_msec() + sys_time_diff + latency

	client_clock = server_clock - INTERPOLATION_OFFSET


func connect_to_server():
	network = NetworkedMultiplayerENet.new()
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("server_disconnected", self, "_server_disconnected")
	network.create_client(ip, port)
	get_tree().set_network_peer(network)


func _server_disconnected():
	print("Connection lost")
	battle_has_ended()
	#get_tree().quit()


func _on_connection_failed():
	print("Faild to connect")
	get_node("/root/Main/PopUp/LoginScreen").login_button.set_disabled(false)

func _on_connection_succeeded():
	print("Succesfully connected")
	rpc_id(1, "fetch_saver_time", OS.get_ticks_msec())
	var timer = Timer.new()
	timer.name = "Timer"
	timer.wait_time = 1
	timer.autostart = true
	timer.connect("timeout", self, "determine_latency")
	self.add_child(timer, true)
	# Enables to click ESC and open menu
	get_node("/root/Main/PopUp").logged = true
	get_node("/root/Main/PopUp").go_to_select_team()


remote func return_server_time(server_time, client_time):
	if get_tree().get_rpc_sender_id() == 1:
		latency = (OS.get_ticks_msec() - client_time) / 2
		sys_time_diff = server_time - OS.get_ticks_msec()
		print(server_time, "|",OS.get_ticks_msec(), "|", sys_time_diff)
		server_clock = server_time + latency

func determine_latency():
	rpc_id(1, "determine_latency", OS.get_ticks_msec())

remote func return_latency(client_time):
	# time difference between server and client
	if get_tree().get_rpc_sender_id() == 1:
		latency_array.append((OS.get_ticks_msec() - client_time) / 2)
		if latency_array.size() == 9:
			var total_latency = 0
			latency_array.sort()
			var mid_point = latency_array[4]
			for i in range(latency_array.size() -1, -1, -1):
				if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
					latency_array.remove(i)
				else:
					total_latency += latency_array[i]
			latency = total_latency / latency_array.size()
#			print("New Latency: ", latency)
			latency_array.clear()

remote func fetch_token():
	if get_tree().get_rpc_sender_id() == 1:
		rpc_id(1, "return_token", token)

remote func return_token_verification_result(result):
	if get_tree().get_rpc_sender_id() == 1:
		if result == true:
			get_node("/root/Main/PopUp/LoginScreen").queue_free()
			get_node("/root/Main/PopUp/SelectTeam").show()
			print("Successful token verification")
		else:
			print("Login faild, please try again")
			get_node("/root/Main/PopUp/LoginScreen").login_button.disable = false
			get_node("/root/Main/PopUp/LoginScreen").login_button.disable = false


func send_initialization(initialization_info):
	rpc_id(1, "recive_player_initialization", initialization_info)

remote func ack_player_initialization(queue):
	if get_tree().get_rpc_sender_id() == 1:
		get_node("/root/Main/PopUp/SelectTeam").sending_initialization_succesful()
		# [info] Cannot select when not spawn
		get_node("/root/Main/PopUp/GameMenu").in_select_team.set_disabled(true)

# [improve] correct name of this varible
remote func recive_general_starting_info(for_new_player_info: Dictionary, this_ship_information):
	if get_tree().get_rpc_sender_id() == 1:
		get_node("/root/Main/PopUp/GameMenu").in_select_team.set_disabled(false)
		# [info] this_ship_information have other information, thats why its separate fron "for_new_player_info"
		Main.self_player_initialization(this_ship_information, for_new_player_info["BT"])
		LocalData.set_multipleS({"UpgradeMultipleS": for_new_player_info["UpgradeMultipleS"]})
		LocalData.set_multipleS({"TaskMultipleS": for_new_player_info["TaskMultipleS"].Multipliers})
		get_node("/root/Main/KapustaControlNode").add_recived_kapusta(for_new_player_info["BegKapusta"])
		Main.spawn_new_players_from_information(for_new_player_info["PInfo"])
		# [info] Map Initialization
		is_player_ready = true
		get_node("/root/Main/Map").spawn_capture_points(for_new_player_info["CapturePointsData"])

# [improve] spawning player is compleatly different than despawning_player xD
remote func spawn_new_player(player_id, player_info: Dictionary):
	if get_tree().get_rpc_sender_id() == 1:
		#[info] Ye, player will get his own copy to create when he connect to game. Its important to spawn player by "starting info" cuz he gets clock time there and its needed.
		if player_id != get_tree().get_network_unique_id():
			# [info] it have to be as dict to be used by function
			player_info = {player_id: player_info}
			Main.spawn_new_players_from_information(player_info)
		else:
			#Main.self_player_initialization(player_info)
			pass

# --------BIDDING AREA-----------
# [info] Only terraship & player on the bid will recive it
remote func recive_bidding(bidding_id, player_info, krxy, _owner):
	if get_tree().get_rpc_sender_id() == 1:
		get_node("/root/Main/PopUp/BiddingTab").bid(bidding_id, player_info, krxy, _owner)
# [improve] add "client_clock" for proper bidding management
func send_bid(bidding_id, bid_amount):
	rpc_id(1, "recive_bid", bidding_id, bid_amount)


# --------UPGRADES AREA-----------
remote func recive_upgrade(propertyS: Dictionary):
	if get_tree().get_rpc_sender_id() == 1:
		LocalData.set_multipleS({"UpgradeMultipleS": propertyS})

func send_upgrade_request(_name):
	rpc_id(1, "get_upgrade_request", _name)

# ------------TASKS---------------
remote func recive_new_task(task_number, task_data: Dictionary):
	if get_tree().get_rpc_sender_id() == 1:
		LocalData.set_multipleS({"TaskMultipleS": task_data.Multipliers})
		task_data.erase("Multipliers")
		LocalData.task_data = task_data
		get_node("/root/Main/GUI/TeamViewNorm").set_task_name(task_number)
		
func send_task_for_playerS(playerS_idS, task_number):
	rpc_id(1, "get_task_for_playerS", playerS_idS, task_number)


# ----------CAP AREA------------
remote func recive_cap_state(_server_time, _name, occuping_team):
	if get_tree().get_rpc_sender_id() == 1 && is_player_ready:
		yield(get_tree().create_timer((_server_time - client_clock) * 0.001), "timeout")
		get_node("/root/Main/Map/" + _name).point_captured(occuping_team)



func self_death():
	rpc_id(1, "own_choice_player_self_death")


remote func despawn_player(player_id, communicate):
	if get_tree().get_rpc_sender_id() == 1:
		if player_id == get_tree().get_network_unique_id():
			print("Reason of despawn: ", LocalData.DES[communicate])
			var gui_node = get_node("/root/Main/GUI")
			gui_node.queue_free()
			Main.remove_child(gui_node)
			get_node(LocalData.PLAYER_PATH).queue_free()
			get_node("/root/Main/KapustaControlNode").reset_spended_kapusta()
			get_node("/root/Main/PopUp/SelectTeam").show_plus()
		else:
			Main.despawn_player_template(player_id)

remote func battle_has_ended():
	# [improve] maybe removing Main node and running it again?
	#if get_tree().get_rpc_sender_id() == 1:
		print("battle_has_ended()")
		$Timer.queue_free()
		get_node("/root/Main").queue_free()
		network.close_connection()
		network.disconnect("connection_failed", self, "_on_connection_failed")
		network.disconnect("connection_succeeded", self, "_on_connection_succeeded")
		network.disconnect("server_disconnected", self, "_server_disconnected")
		yield(get_node("/root/Main"), "tree_exited")
		var main_node = main_tscn.instance()
		get_parent().add_child(main_node, true)
		Main = get_node("/root/Main")
#		Main.despawn_all_templated_players()
#		get_node("/root/Main/KapustaControlNode").reset_spended_kapusta()
#		if Main.has_node("/root/Main/GUI"):
#			var gui_node = get_node("/root/Main/GUI")
#			gui_node.queue_free()
#			Main.remove_child(gui_node)
#			get_node(LocalData.PLAYER_PATH).queue_free()
#		var bid_node = get_node("/root/Main/PopUp/BiddingTab")
#		if Main.has_node("/root/Main/PopUp/BiddingTab"):
#			bid_node._on_BidTime_timeout()
#		get_node("/root/Main/PopUp/SelectTeam").show_plus()
		print("Reason of despawn: Battle has ended")


# [improve] Is it okey?? to make unreable_attack
func send_unreliable_attack(shoots_state):
	shoots_state = {server_clock: shoots_state}
	rpc_unreliable_id(1, "recive_unreable_attack", shoots_state)

remote func receive_unreable_attack(player_id, shoot_state):
	if get_tree().get_rpc_sender_id() == 1:
		if player_id == get_tree().get_network_unique_id():
			pass
		else:
			# [improve] Maybe making var of get_node is faster way
			var shooter = get_node_or_null("/root/Main/PlayersWorld/"  + str(player_id))
			if shooter != null:
				shooter.attack_dict[shoot_state.keys()[0]] = shoot_state.values()[0]

func send_player_state(player_state):
	rpc_unreliable_id(1, "recive_player_state", player_state)

remote func recive_world_state(world_state):
	if get_tree().get_rpc_sender_id() == 1 && get_parent().has_node("Main"):
		#print("World State: ", world_state["T"], " | client clock: ", server_clock, " | Diff: ",  world_state["T"] - server_clock)
		Main.update_world_state(world_state)
		time_diff_make_counter += 1
		if time_diff_make_counter >= 10:
			determine_time_diff(world_state["T"])
			time_diff_make_counter = 0
#Update_world_state instance freed

func determine_time_diff(server_time: int):
	sys_time_diff_array.append(server_time - OS.get_ticks_msec())
	if sys_time_diff_array.size() == 9:
			var total_sys_time_diff = 0
			sys_time_diff_array.sort()
			var mid_point_sys = sys_time_diff_array[4]
			for i in range(sys_time_diff_array.size() -1, -1, -1):
				if abs(sys_time_diff_array[i]) > (2 * mid_point_sys) and abs(sys_time_diff_array[i]) < 20:
					sys_time_diff_array.remove(i)
				else:
					total_sys_time_diff += sys_time_diff_array[i]
			if total_sys_time_diff != 0:
				sys_time_diff = total_sys_time_diff / sys_time_diff_array.size()
				#print("New sys_time_diff: ", sys_time_diff)
				sys_time_diff_array.clear()
