extends AB_ShipCore_P

# engines
onready var right_engine = $Pivot/Engines/REngine
onready var left_engine = $Pivot/Engines/LEngine
onready var r_wing_move_fire = $Pivot/Engines/RHoryzontalMove
onready var l_wing_move_fire = $Pivot/Engines/LHoryzontalMove
onready var r_wing_rotation_fire = $Pivot/Engines/RWingRotate
onready var r_wing_rotation_fire_front = $Pivot/Engines/RWingRotateFront
onready var l_wing_rotation_fire = $Pivot/Engines/LWingRotate
onready var l_wing_rotation_fire_front = $Pivot/Engines/LWingRotateFront

onready var GunTurrets_Array = $Pivot/FixedTurrets.get_children()





func _physics_process(delta):
	actual_speed = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
	define_rotation_extend(delta)
	define_movement(delta)
	applay_rotation(actual_rotation)
	main_engine_on_visibility(is_accelerate, left_engine, right_engine)
	rotate_engines_visibility(rotation_dir, r_wing_rotation_fire_front, l_wing_rotation_fire_front, r_wing_rotation_fire, l_wing_rotation_fire)
	map_edge()
	send_player_state(define_player_position_and_time())
#	$Pivot/Engines/LEngine.get_process_material().set_param(0, 300 + actual_speed)


func get_shoot_state() -> Array:
	return [
			GunTurrets_Array[0].shoot(),
			GunTurrets_Array[1].shoot()
	]


func define_rotation_extend(delta):
	rotation_dir = Input.get_axis("left", "right")
	side_movement_animation(0)
	if Input.is_action_pressed("mouse_right"):
		if rotation_dir == 1 and not(Input.is_action_pressed("down")):
			side_movement_animation(rotation_dir)
			velocity += Vector2(acceleration * 0.5, 0).rotated(actual_rotation + PI * 0.5)
		elif rotation_dir == -1 and not(Input.is_action_pressed("down")):
			side_movement_animation(rotation_dir)
			velocity += Vector2(acceleration * 0.5, 0).rotated(actual_rotation - PI * 0.5)
		var mouse_position = get_local_mouse_position()
		var angle_diff = Vector2(1,0).rotated(actual_rotation).angle_to(mouse_position)
		if angle_diff > 0:
			rotation_dir = 1
		elif angle_diff < 0:
			rotation_dir = -1
		else:
			rotation_dir = 0
		if abs(angle_diff) <= 0.05:
			actual_rotation = get_local_mouse_position().angle()
			rotation_dir = 0
	actual_rotation += deg2rad(rotation_dir * rotation_speed * delta)
	if actual_rotation > PI:
		actual_rotation = - PI
	elif actual_rotation < - PI:
		actual_rotation = PI

func side_movement_animation(side_dir):
	if side_dir == 1:
		r_wing_move_fire.hide()
		l_wing_move_fire.show()
	elif side_dir == -1:
		l_wing_move_fire.hide()
		r_wing_move_fire.show()
	else:
		r_wing_move_fire.hide()
		l_wing_move_fire.hide()

