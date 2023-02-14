extends Node2D

var tscn_shoot = preload("../Shoots/PlayerLaser.tscn")

onready var in_turret_gun = $TurretGun
onready var in_cast_point = $TurretGun/CastPoint



func shoot() -> Dictionary:
	var laser_instance = tscn_shoot.instance()
	var shoot_position = in_cast_point.get_global_position()
	var proper_rotation = in_cast_point.get_global_rotation()
	var shoot_state = {"P": shoot_position, "R": proper_rotation}
	laser_instance.position = shoot_position
	laser_instance.rotation = proper_rotation
	get_node("/root/Main/ProjectileWorld").add_child(laser_instance)
	return shoot_state
