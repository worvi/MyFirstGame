extends Node2D

var tscn_shoot = preload("../Shoots/PlayerLaser.tscn")

onready var in_turret_gun = $TurretBase/TurretGun
onready var in_cast_point = $TurretBase/TurretGun/CastPoint
var gun_turret_rotation = 0

func _process(delta: float) -> void:
	in_turret_gun.rotation = get_local_mouse_position().angle() + deg2rad(-90)
	gun_turret_rotation = get_local_mouse_position().angle() + deg2rad(-90)

func shoot() -> Dictionary:
	# [improve] change it similiar to Fixed one
	var laser_instance = tscn_shoot.instance()
	var shoot_position = in_cast_point.get_global_position()
	var proper_rotation = in_turret_gun.global_rotation + deg2rad(90)
	var shoot_state = {"P": shoot_position, "R": proper_rotation}
	laser_instance.position = shoot_position
	laser_instance.rotation = proper_rotation
	get_node("/root/Main/ProjectileWorld").add_child(laser_instance)
	return shoot_state
