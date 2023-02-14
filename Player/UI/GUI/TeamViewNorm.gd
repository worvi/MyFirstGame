extends Control

var time = null #seconds

func _enter_tree():
	if get_node("/root/Main").my_ship_type == "TerraShip":
		self.hide()
	else:
		self.show()

func set_task_name(task_number):
	$VBoxContainer/Task.text = LocalData.taskS[task_number]
	if task_number == LocalData.TASK.SELF_DESTRUCTION:
		$DestructionTime.set_visible(true)
		get_parent().get_node("ActualizeScreenTime").connect("timeout", self, "reload_task_timer")
	if task_number == LocalData.TASK.CAPUTRE_POINTS:
		caputre_points_logic(true)

func reload_task_timer():
	var time_of_destruction = LocalData.task_data.SelfDestructionAbsTime
	var time = str(int(time_of_destruction - GameServer.client_clock) / 1000)
	$DestructionTime.text = time

func caputre_points_logic(is_active):
	pass
