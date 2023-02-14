extends Control
var TASK = LocalData.TASK
func button_pressed(task_number):
	GameServer.send_task_for_playerS(get_parent().pressed_buttons, task_number)
	self.hide()
	# [info] changing task name for selected players
	for pressed_button in get_parent().pressed_buttons:
		get_parent().get_node("Separator/ShipTask/" + str(pressed_button)).text = LocalData.taskS[task_number]
		get_parent().get_node("Separator/ShipTask/" + str(pressed_button)).set_pressed(false)
		if task_number == TASK.SELF_DESTRUCTION:
			get_parent().get_node("Separator/ShipTask/" + str(pressed_button)).set_disabled(true)
			get_parent().get_node("Separator/ShipType/" + str(pressed_button)).set_disabled(true)
			
	get_parent().pressed_buttons.clear()


# [info] There are number instead names in case 'cheater' changing name and sending own task name
func _on_SelfDestruction_pressed():
	button_pressed(TASK.SELF_DESTRUCTION)


func _on_Attack_pressed():
	button_pressed(TASK.ATTACK)


func _on_Defend_pressed():
	button_pressed(TASK.DEFEND)


func _on_CapturePoints_pressed():
	button_pressed(TASK.CAPUTRE_POINTS)
