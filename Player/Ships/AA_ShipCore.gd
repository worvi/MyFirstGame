extends KinematicBody2D
class_name AA_ShipCore

# health bar
var max_hp = -1
var current_hp: float = -1
onready var hp_bar_pivot = $HPBar/Pivot
onready var hp_bar = $HPBar


# [improve] make that SERVER sets position of player, when values are impossible
func _ready():
	self.add_to_group("Players")
	current_hp = max_hp

# [improve] change 4 vars to 2 arrays end edit things in this arrays
func rotate_engines_visibility(rotation_dir, right_front, left_front, right_back, left_back):
	if rotation_dir == 1:
		right_front.show()
		left_front.hide()
		right_back.hide()
		left_back.show()
	elif rotation_dir == -1:
		right_front.hide()
		left_front.show()
		right_back.show()
		left_back.hide()
	else:
		right_front.hide()
		left_front.hide()
		right_back.hide()
		left_back.hide()


func main_engine_on_visibility(is_engine_on: bool, left_engine, right_engine):
	if is_engine_on == true:
		left_engine.emitting = true
		right_engine.emitting = true
	else:
		left_engine.emitting = false
		right_engine.emitting = false


func change_hp(new_hp):
	hp_bar.hpbar_update(new_hp)

func change_velocity(new_velocity):
	hp_bar.velocity_update(String(new_velocity))
