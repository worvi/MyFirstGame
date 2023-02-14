extends AB_ShipCore_P

onready var GunTurret = $Pivot/GunTurret
onready var in_turret_gun = $Pivot/GunTurret/TurretBase/TurretGun

# engines
onready var right_engine = $Pivot/Engines/REngine
onready var left_engine = $Pivot/Engines/LEngine
onready var r_wing_rotation_fire = $Pivot/Engines/RWingRotate
onready var r_wing_rotation_fire_front = $Pivot/Engines/RWingRotateFront
onready var l_wing_rotation_fire = $Pivot/Engines/LWingRotate
onready var l_wing_rotation_fire_front = $Pivot/Engines/LWingRotateFront




func _physics_process(delta):
	actual_speed = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
	define_rotation(delta)
	define_movement(delta)
	applay_rotation(actual_rotation)
	main_engine_on_visibility(is_accelerate, left_engine, right_engine)
	rotate_engines_visibility(rotation_dir, r_wing_rotation_fire_front, l_wing_rotation_fire_front, r_wing_rotation_fire, l_wing_rotation_fire)
	map_edge()
	send_player_state(define_player_position_and_time())


func get_shoot_state() -> Array:
	return [GunTurret.shoot()]

func addition_to_player_state() -> Dictionary:
	var dict = {"GR": GunTurret.in_turret_gun.rotation}
	return dict
