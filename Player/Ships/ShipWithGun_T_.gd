extends AB_ShipCore_T

onready var GunTurret = $Pivot/GunTurret
onready var in_turret_gun = $Pivot/GunTurret/TurretBase/TurretGun
var empty_script_gd: Reference = preload("res://EmptyScript.gd")
# engines
onready var right_engine = $Pivot/Engines/REngine
onready var left_engine = $Pivot/Engines/LEngine
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
	GunTurret.set_script(empty_script_gd)
	

func manage_template_state(previous_state, next_state, interpolation_factor):
	manage_position(previous_state["Location"]["P"], next_state["Location"]["P"], interpolation_factor)
	manage_rotation(previous_state["Location"]["R"][0], next_state["Location"]["R"][0], interpolation_factor)
	manage_gun_position(previous_state["GR"], next_state["GR"], interpolation_factor)
	main_engine_on_visibility(next_state["Location"]["ACC"], left_engine, right_engine)
	rotate_engines_visibility(previous_state["Location"]["R"][1], r_wing_rotation_fire_front, l_wing_rotation_fire_front, r_wing_rotation_fire, l_wing_rotation_fire)
	change_hp(next_state.HP)
	change_velocity(previous_state["V"])


func manage_gun_position(revious_gun_rotation, next_gun_rotation, interpolation_factor):
	var new_gun_rotation = lerp_angle(revious_gun_rotation, next_gun_rotation, interpolation_factor)
	in_turret_gun.set_rotation(new_gun_rotation)
