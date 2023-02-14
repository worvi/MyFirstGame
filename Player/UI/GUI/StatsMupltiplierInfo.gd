extends Control
const COST_OF_UPGRADES = 50

# [convention] Big "S" at the end bcs there are multiple items as this varible
onready var in_nameS = {
		"Damage": $HBoxContainer/NameContainer/DamageContainer/DamageName/DamageValue,
		"Acceleration": $HBoxContainer/NameContainer/AccelerationContainer/AccelerationName/AccelerationValue
}
onready var in_buttonS = {
		"Damage": $HBoxContainer/ButtonsContainer/DamageButton,
		"Acceleration": $HBoxContainer/ButtonsContainer/AccelerationButton
}


func _enter_tree():
	if get_node("/root/Main").my_ship_type != "TerraShip":
		$HBoxContainer/ButtonsContainer.hide()
	else:
		$HBoxContainer/ButtonsContainer.show()

func display_value():
	for statistic in LocalData.terminal_multipleS:
		in_nameS[statistic].text = str(LocalData.terminal_multipleS[statistic] * 100)  + "%"
		in_buttonS[statistic].disabled = false

func _on_AccelerationButton_pressed():
	button_pressed("Acceleration")


func _on_DamageButton_pressed():
	button_pressed("Damage")



func button_pressed(property: String):
	if get_node(LocalData.KAPUSTA_PATH).check_is_enough_kapusta(COST_OF_UPGRADES, true):
		in_buttonS[property].disabled = true
		GameServer.send_upgrade_request(property)


