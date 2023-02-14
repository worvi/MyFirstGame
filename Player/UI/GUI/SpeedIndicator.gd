extends Control

# Speed

onready var SpeedLabel = $TextureRect/SpeedLabel



func _process(_delta: float) -> void:
	actualize_speed()

# [improve] Is it okey to getnode every time? Is maybe "signal" better??
func actualize_speed():
	var SpeedValue = get_node(LocalData.PLAYER_PATH).actual_speed
	SpeedLabel.text = str(int(SpeedValue))
