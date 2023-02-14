extends Control

onready var standard_ship = $Background/TeamScreen/Ships/StandardShipButton
onready var n_ship_with_gun = $Background/TeamScreen/Ships/ShipWithGunButton

func _ready() -> void:
	self.hide()


func _on_StandardShipButton_pressed() -> void:
	n_ship_with_gun.set_pressed(false)

func _on_ShipWithGunButton_pressed() -> void:
	standard_ship.set_pressed(false)



func _on_Confirm_pressed() -> void:
	# [improve] take care about naming. This node and Gameserver node
	var ships_dict = {"StandardShip": standard_ship.is_pressed(), "ShipWithGun":  n_ship_with_gun.is_pressed()}
	if (standard_ship.is_pressed() or n_ship_with_gun.is_pressed()):
		var ship_type: String = "-1"
		for d_ship in ships_dict:
			if ships_dict[d_ship] == true:
				ship_type = d_ship
				break
		button_pressed(ship_type)

func button_pressed(ship_type):
	n_ship_with_gun.disabled = true
	standard_ship.disabled = true
	# [improve] take care about naming. This node and Gameserver node
	var initialization_info = {"ST": ship_type}
	GameServer.send_initialization(initialization_info)
	#yield(get_tree().create_timer(2.0), "timeout")
	n_ship_with_gun.disabled = false
	standard_ship.disabled = false
	

func sending_initialization_succesful():
	n_ship_with_gun.disabled = true
	standard_ship.disabled = true
	self.hide()

func show_plus():
	n_ship_with_gun.disabled = false
	standard_ship.disabled = false
	show()
