extends AB_ShipCore_T




func _init():
	$Pivot/GunTurrets.free()


func _ready() -> void:
	ships_asset = {
	"Ally": preload("res://assets/PNG/ufoBlue.png"),
	"Enemy": preload("res://assets/PNG/ufoRed.png")
	}
	base_ready()
	hp_bar_pivot.scale = Vector2(5, 3)


func manage_template_state(previous_state, next_state, interpolation_factor):
	manage_position(previous_state["Location"]["P"], next_state["Location"]["P"], interpolation_factor)
	manage_rotation(previous_state["Location"]["R"][0], next_state["Location"]["R"][0], interpolation_factor)
	change_hp(next_state.HP)
	change_velocity(previous_state["V"])
