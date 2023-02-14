extends AB_ShipCore_P


var gun_turrets_indicator = 0
onready var GunTurrets = $Pivot/GunTurrets
onready var gun_turrets_number = GunTurrets.get_children().size()


func _init() -> void:
	set_collision_mask(0)

func _ready():
	hp_bar_pivot.scale = Vector2(5, 3)



func _physics_process(delta):
	actual_speed = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
	define_rotation(delta)
	define_movement(delta)
	applay_rotation(actual_rotation)
	map_edge()
	send_player_state(define_player_position_and_time())


func define_rotation(delta):
	actual_rotation += deg2rad(rotation_speed * delta)
	if actual_rotation > PI:
		actual_rotation = - PI
	elif actual_rotation < - PI:
		actual_rotation = PI
	pivot.rotation = actual_rotation

func define_movement(delta):
	var vertical_movment = Input.get_axis("up", "down")
	var horyzontal_movement = Input.get_axis("left", "right")
	velocity = Vector2(horyzontal_movement * acceleration, vertical_movment * acceleration)
	# [improve] add property normalized
	velocity = move_and_slide(velocity)



func get_shoot_state() -> Array:
	gun_turrets_indicator = (gun_turrets_indicator + 1) % gun_turrets_number
	return [GunTurrets.get_children()[gun_turrets_indicator].shoot()]

