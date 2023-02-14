extends Node
# [info] Checking is made in a little future so server is ahead 100 ms before such transaction
# [info] every 10 sec + 10;
# [info] Thats in seconds
var begining_time_of_battle: int

func current_base_kapusta() -> int:
	return int((OS.get_ticks_msec()*0.001 - begining_time_of_battle) * 0.1)*10

func add_spended_kapusta(player_id, amount):
	get_node("../PlayersNode/" + str(player_id)).spended_kapusta += amount
	
func add_recived_kapusta(player_id, amount):
	get_node("../PlayersNode/" + str(player_id)).spended_kapusta -= amount

func get_player_spended_kapusta(player_id) -> int:
	return get_node("../PlayersNode/" + str(player_id)).spended_kapusta

func is_transaction_possible(player_id, amount_to_spend) -> bool:
	if current_base_kapusta() - get_player_spended_kapusta(player_id) - amount_to_spend >= 0:
		return true
	return false
