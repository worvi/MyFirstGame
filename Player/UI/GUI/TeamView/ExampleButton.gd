extends Button

signal pressed_button_with_name
signal mouse_enter_with_name
signal mouse_exit_with_name



func _on_Example_toggled(is_button_pressed):
	emit_signal("pressed_button_with_name", is_button_pressed, name)


func _on_Example_mouse_entered():
	get_node(LocalData.TEMPLATES_PATH + "/" + name).highlight()


func _on_Example_mouse_exited():
	get_node(LocalData.TEMPLATES_PATH + "/" + name).stop_highlight()


func _on_Example_pressed():
	emit_signal("pressed_button_with_name", name)
