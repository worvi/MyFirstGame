extends Control

var pressed_buttons: Array
onready var in_example_nodeS = {
		"ShipType":$Separator/ShipType/Example, 
		"Task": $Separator/ShipTask/Example
}
onready var in_container_nodeS = {
		"ShipType":$Separator/ShipType, 
		"Task": $Separator/ShipTask
}



# [improve] instead of hiding better to queue free and managing setting necessary nodes
func _enter_tree():
	if get_node("/root/Main").my_ship_type != "TerraShip":
		self.hide()
	else:
		self.show()

func _ready():
	in_example_nodeS.ShipType.hide()
	in_example_nodeS.Task.hide()
	$Back.hide()

func add_ship(player_id: String, nameS):
	for key_name in nameS:
		var ship_node = in_example_nodeS[key_name].duplicate()
		ship_node.name = player_id
		ship_node.text = nameS[key_name]
		ship_node.show()
		in_container_nodeS[key_name].add_child(ship_node)

func delete_ship(player_id):
	for container_node in in_container_nodeS.values():
		if !container_node.has_node(str(player_id)):
			return
		container_node.get_node(str(player_id)).queue_free()


func _on_Example_pressed_button_with_name(button_pressed, _name):
	if button_pressed:
		pressed_buttons.append(int(_name))
	else:
		pressed_buttons.erase(int(_name))
	
	if pressed_buttons.size() > 0:
		$TaskSelection.show()
	else:
		$TaskSelection.hide()



func _on_Back_pressed():
	get_node(LocalData.PLAYER_PATH + "/Camera2D")._set_current(true)
	$Back.hide()

func _on_ShipType_Example_pressed_button_with_name(_name):
	get_node(LocalData.TEMPLATES_PATH + "/" + _name + "/Camera2D")._set_current(true)
	$Back.show()
