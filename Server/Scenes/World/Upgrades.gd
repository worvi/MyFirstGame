extends Node

func get_multiplier(team_id, property):
	return ServerData.multipliers[team_id][property]

func verification(this_terra_id, amount) -> bool:
	if !get_parent().terra_ship_information.has(this_terra_id):
		print("[Upgrades]: ",this_terra_id, " wanted to make upgrade (its not terra)")
		return false
	if  !get_node("../KapustaControlNode").is_transaction_possible(this_terra_id, amount):
		print("[Upgrades] Transaction isn't possible. Not enough money")
		return false
	return true

func upgrade_from_terraship(terra_ship_id, property_name):
	if !verification(terra_ship_id, ServerData.COST_OF_UPGRADES):
		return
	var team_id = get_parent().terra_ship_information[terra_ship_id]["T"]
	get_node("../KapustaControlNode").add_spended_kapusta(terra_ship_id, ServerData.COST_OF_UPGRADES)
	increase_multiplier(team_id, property_name, ServerData.MULTIPLIER_INCREMENTOR)

func increase_multiplier(team_id, property_name, multiplier_val):
	ServerData.multipliers[team_id][property_name] += multiplier_val
	for player in get_tree().get_nodes_in_group("Team" + str(team_id)):
		get_node("/root/GameServer").send_current_multiplier(
				int(player.name), {property_name: ServerData.multipliers[team_id][property_name]})

