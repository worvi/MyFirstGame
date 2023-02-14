extends AA_ShipCore
class_name AB_ShipCore_T
# [improve] Think about setting team/ sprite skin in one way not in both (when player already exist and will appear in future)

var ships_asset
var lasers_asset = {
	"Ally": preload("./Shoots/AllyLaser.tscn"),
	"Enemy": preload("./Shoots/EnemyLaser.tscn")
}
var attack_dict = {}
#[improve] remove this team- its not used any more
var team = {}
var ship_type: String

onready var tween = $Tween
onready var pivot = $Pivot
onready var sprite = $Pivot/Sprite
onready var highlight = $Pivot/Highlight
onready var collision_polygon = $CollisionShape


var init_rotation = 0


func base_ready():
	set_texture()
	pivot.set_rotation(init_rotation)
	collision_polygon.set_rotation(init_rotation)


func init(player_id: int, player_information: Dictionary, my_team_id: int):
	name = str(player_id)
	position = player_information.Location.P
	init_rotation = player_information.Location.R
	team["ID"] = player_information.T
	var relevant_team = null
	if player_information.T == my_team_id:
		relevant_team = "Ally"
	else:
		relevant_team = "Enemy"
	set_team_properites(relevant_team)
	team["Relevant"] = relevant_team
	max_hp = player_information.MaxHP
	ship_type = player_information.ST

func set_team_properites(relative_team):
	if relative_team == "Ally":
		add_to_group("Ally")
		set_collision_layer(4)
		set_collision_mask(64)
	elif relative_team == "Enemy":
		add_to_group("Enemy")
		set_collision_layer(2)
		set_collision_mask(68)
	else:
		print("There is no such grup! ", relative_team)

func set_texture():
	sprite.set_texture(ships_asset[team.Relevant])


func _physics_process(_delta: float) -> void:
	if not attack_dict == {}:
		attack()


func manage_position(previous_position, next_position, interpolation_factor):
	var new_position = lerp(previous_position, next_position, interpolation_factor)
	set_position(new_position)

func manage_rotation(previous_rotation, next_rotation, interpolation_factor):
	var new_rotation = lerp_angle(previous_rotation, next_rotation, interpolation_factor)
	pivot.set_rotation(new_rotation)
	collision_polygon.set_rotation(new_rotation)

func manage_gun_rotation(previous_rotation, next_rotation, interpolation_factor):
	var new_gun_rotation = lerp_angle(previous_rotation, next_rotation, interpolation_factor)
	$Pivot/GunTurret/TurretBase/TurretGun.rotation = new_gun_rotation

func is_accelerating(previous_velocity, next_velocity) -> bool:
	return bool(1 if previous_velocity < next_velocity else 0)


func attack():
	for attack in attack_dict.keys():
		if attack <= GameServer.client_clock:
			for shoot in attack_dict[attack]:
				var laser_instance = lasers_asset[team.Relevant].instance()
				laser_instance.position = shoot["P"]
				laser_instance.rotation = shoot["R"]
				get_node("/root/Main/ProjectileWorld").add_child(laser_instance)
			attack_dict.erase(attack)

func on_death():
	# [info] Okey, so potential problem is here, because it seems possible that player firstly be hided
	# because of no info in main player function (same when out of vision) and destroy animation woundn't be seen
	queue_free()


func highlight():
	highlight.show()
	
func stop_highlight():
	highlight.hide()
