extends Node

var counter = 0
var world_state = {}
var player_hp = {}

func start_timer():
	$Timer.start()

func stop_timer():
	$Timer.stop()

func _on_Timer_timeout():
	world_state = get_parent().playerS_state_collection.duplicate(true)
	for player in world_state.keys():
		world_state[player]["HP"] = player_hp[player]["HP"]
	world_state["T"] = OS.get_ticks_msec()
	# Verification
	# Anti-cheate
	get_node("/root/GameServer").send_world_state(world_state)


func _on_Timer_timeout_NEW(): #This function is to end and use when Vision system will be implementing
	for player in get_tree().get_nodes_in_group("Team" + str(counter + 1)):
		world_state = get_parent().playerS_state_collection.duplicate(true)
#		for player in world_state.keys():
#			world_state[player].erase("T")
#			world_state[player]["HP"] = player_hp[player]["HP"]
		world_state["T"] = OS.get_ticks_msec()
		# Verification
		# Anti-cheate
		get_node("/root/GameServer").send_world_state(world_state)
	counter = (counter + 1) % 2
