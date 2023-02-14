extends CanvasLayer







#--------------Time-battle-management-----------------

var begining_time_of_battle: int setget set_begining_time_of_battle
var battle_time: int = 0
var time_difference: float = 0
onready var in_timer = $ActualizeScreenTime
onready var in_screen_battle_time = $ScreenBattleTime
onready var in_screen_kapusta = $ScreenKapusta


func _exit_tree():
	set_begining_time_of_battle(0)


func set_begining_time_of_battle(_beggining_time: int):
	if _beggining_time == 0:
		battle_time = 0
		in_timer.stop()
		in_screen_battle_time.actualize_time(battle_time)
	else:
		time_difference = battle_time - (GameServer.client_clock - _beggining_time) * 0.001
		battle_time = (GameServer.client_clock - _beggining_time) * 0.001 + 1
		in_timer.start(1 + time_difference)
		time_difference = 0
		in_screen_kapusta.actualize_kapusta()
	begining_time_of_battle = _beggining_time

func _on_ActualizeScreenTime_timeout():
	battle_time += 1
	time_difference = battle_time - (GameServer.client_clock - begining_time_of_battle) * 0.001
	if time_difference > 0 or time_difference < -0.02:
		#print(time_difference)
		in_timer.start(1 + time_difference * 0.9)
		in_timer.set_wait_time(1)
	in_screen_battle_time.actualize_time(battle_time)
	if !(battle_time % 10):
		in_screen_kapusta.actualize_kapusta()

