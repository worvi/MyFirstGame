extends Node
# [info] Checking is made in a little future so server is ahead 100 ms before such transaction
# [info] So its 100 at the beginning and every 10 sec + 10;
# [info] Thats in seconds
var begining_time_of_battle: int
var spended_kapusta: int = 0

func current_base_kapusta() -> int:
	return int((GameServer.client_clock*0.001 - begining_time_of_battle) * 0.1)*10 - spended_kapusta

func current_kapusta() -> int:
	return int((GameServer.client_clock*0.001 - begining_time_of_battle) * 0.1)*10 - spended_kapusta

func add_spended_kapusta(amount):
	spended_kapusta += amount
	get_node("../GUI/ScreenKapusta").actualize_kapusta()

func add_recived_kapusta(amount):
	spended_kapusta -= amount
	get_node("../GUI/ScreenKapusta").actualize_kapusta()

func reset_spended_kapusta():
	spended_kapusta = 0

func check_is_enough_kapusta(kapusta_to_spend, is_to_spend = false) -> bool:
	if current_base_kapusta() - kapusta_to_spend < 0:
		print("Not enought kapusta :<")
		return false
	if is_to_spend:
		add_spended_kapusta(kapusta_to_spend)
	return true
