extends RigidBody2D

const DAMAGE_MULTIP = "Damage"
var speed = ServerData.weapons_data.Laser.Speed
var damage = ServerData.weapons_data.Laser.Damage
var life_time = ServerData.weapons_data.Laser.LifeTime
# [improve] Which way is better? To use data.Speed or to asing to var speed correct data???
var data = ServerData.weapons_data.Laser
var direction
var player_id
var player_damage
var player_team

func _init():
	var timer = Timer.new()
	timer.name = "Cooldown"
	timer.autostart = true
	timer.wait_time = life_time
	timer.connect("timeout", self, "self_destruct")
	add_child(timer)

func init(_player_id, _player_team, _player_damage: float, shoot_state):
	player_team = _player_team
	if player_team == 1:
		set_collision_mask(36)
	else:
		set_collision_mask(34)
	player_id = str(_player_id)
	position = shoot_state.P
	direction = shoot_state.R
	rotation = shoot_state.R
	player_damage = _player_damage

func _ready() -> void:
	set_damage([
		player_damage,
		get_node("/root/GameServer/WorldMap/Upgrades").get_multiplier(player_team, DAMAGE_MULTIP)
	])
	apply_impulse(Vector2(), Vector2(speed, 0).rotated(direction))

func set_damage(damage_percent_valueS):
	for damage_percentage in damage_percent_valueS:
		damage *= damage_percentage

func self_destruct():
	queue_free()

func _on_Laser_body_entered(body: Node) -> void:
	self.hide()
	$CollisionShape2D.set_deferred("disable", true)
	if body.is_in_group("Players"):
		body.on_hit(damage)
	queue_free()
	self.set_deferred("contact_monitor", false)

