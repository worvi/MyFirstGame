extends Control

onready var in_select_team = $Background/GameMenu/SelectTeam

func _on_Exit_pressed() -> void:
	get_tree().quit()


func _on_SelectTeam_pressed() -> void:
	self.hide()
	GameServer.self_death()
	get_node("../SelectTeam").show()
