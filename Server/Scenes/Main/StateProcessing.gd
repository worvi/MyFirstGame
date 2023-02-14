extends Node

var world_state = {}
var player_hp = {}


#func _on_Timer_timeout():
#	if !get_parent().player_state_collection.empty():
#		world_state = get_parent().player_state_collection.duplicate(true)
#		for player in world_state.keys():
#			world_state[player].erase("T")
#			world_state[player]["HP"] = player_hp[player]["HP"]
#		world_state["T"] = OS.get_ticks_msec()
#		# Verification
#		# Anti-cheate
#		get_node("/root/GameServer").send_world_state(world_state)
