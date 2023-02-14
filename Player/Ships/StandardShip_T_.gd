extends AB_ShipCore_T



# engines
onready var right_engine = $Pivot/Engines/REngine
onready var left_engine = $Pivot/Engines/LEngine
onready var r_wing_move_fire = $Pivot/Engines/RHoryzontalMove
onready var l_wing_move_fire = $Pivot/Engines/LHoryzontalMove
onready var r_wing_rotation_fire = $Pivot/Engines/RWingRotate
onready var r_wing_rotation_fire_front = $Pivot/Engines/RWingRotateFront
onready var l_wing_rotation_fire = $Pivot/Engines/LWingRotate
onready var l_wing_rotation_fire_front = $Pivot/Engines/LWingRotateFront

func _ready() -> void:
	ships_asset = {
	"Ally": preload("res://assets/PNG/playerShip1_blue.png"),
	"Enemy": preload("res://assets/PNG/playerShip1_red.png")
	}
	base_ready()
	# [improve] GunTurret.set_script(empty_script_gd) properly
	# [improve] Is it possible to call function when nodes are in array
	

func manage_template_state(previous_state, next_state, interpolation_factor):
	manage_position(previous_state["Location"]["P"], next_state["Location"]["P"], interpolation_factor)
	manage_rotation(previous_state["Location"]["R"][0], next_state["Location"]["R"][0], interpolation_factor)
	#main_engine_on_visibility(is_accelerating(previous_state["V"], next_state["V"]), left_engine, right_engine)
	main_engine_on_visibility(next_state["Location"]["ACC"], left_engine, right_engine)
	rotate_engines_visibility(previous_state["Location"]["R"][1], r_wing_rotation_fire_front, l_wing_rotation_fire_front, r_wing_rotation_fire, l_wing_rotation_fire)
	change_hp(next_state.HP)
	change_velocity(previous_state["V"])
