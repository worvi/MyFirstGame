extends Node

var T = ServerData.TASK

# [info] IMPORTANT: ADDING TASK HERE, ADD ALSO IN "Local data" to set display name
var task_data = ServerData.task_data


func verification(terra_ship_id, playerS_ids, task_number) -> bool:
	if !get_parent().terra_ship_information.has(terra_ship_id):
		print("[Tasks]: ",terra_ship_id, " wanted to make upgrade")
		return false
	# [info] the is int in case using letter (as cheater) and setting "WIN" task
	if !task_data.has(int(task_number)):
		print("[Tasks]: ",terra_ship_id, " wanted to use other task number: ", task_number)
		return false
	var team_id = get_parent().terra_ship_information[terra_ship_id]["T"]
	var memberS_of_team = get_tree().get_nodes_in_group("Team" + str(team_id))
# [improve] -----------MAKE THIS WORKING------------
#	for player_id in playerS_ids:
#		if !memberS_of_team.has(str(player_id)):
#			print("[Tasks]: ",terra_ship_id, " wrong player id: ", player_id)
#			return false
	return true

func manage_new_task(terra_ship_id, playerS_ids, task_number):
	if !verification(terra_ship_id, playerS_ids, task_number):
		return 
	for player_id in playerS_ids:
		# [improve] Is it better option for doing that
		if get_node("../PlayersNode").has_node(str(player_id)):
			get_node("../PlayersNode/" + str(player_id)).set_task(task_number, task_data[task_number])
	
