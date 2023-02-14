extends AA_ShipCore
class_name AB_ShipCore_P

# movement
var base_acceleration = -1
var acceleration = base_acceleration
export (int) var rotation_speed = 300
export (float )var slow_speed = 3.5
var current_slow: float = 0
var velocity = Vector2()
var actual_rotation = 0
var rotation_dir = 0
var is_engine_on: bool = 0
var actual_speed = 0
var is_accelerate: bool

# shooting
export var rate_of_fire = 0.1
var on_weapon_cooldown = false
var is_firing = false
onready var cooldown = $Cooldown


# camera 
var cam_step: float = 0.1
var cam_actual_zoom: float 
onready var Cam = $Camera2D

# map limits
var map_limit_left = -4000
var map_limit_bottom = 4000
var map_limit_right = 4000
var map_limit_top = -4000

# others
# [info] You are always an ally
var team: Dictionary = {"Relevant": "Ally"} # "ID": Number of team "Relevant" "Ally" or "Enemy"
onready var pivot = $Pivot
onready var tween = $Tween
onready var collision_polygon = $CollisionShape
onready var sprite = $Pivot/Sprite


func _init():
	var timer = Timer.new()
	timer.name = "Cooldown"
	timer.wait_time = rate_of_fire
	timer.connect("timeout", self, "_cooldown")
	add_child(timer, true)


func init(player_information):
	position = player_information.Location.P
	actual_rotation = player_information.Location.R
	max_hp = player_information.MaxHP
	base_acceleration = player_information.BaseAcceleration
	# [info] beginning stats
	rate_of_fire = player_information.RateOfFire
	team["ID"] = player_information.T
	current_hp = max_hp


func _ready() -> void:
	# [info] Own ship 5% bigger bcs getting shot may be little off
	sprite.set_scale(sprite.get_scale() * 1.05)
	Cam._set_current(true)
	cam_actual_zoom = Cam.get_zoom().x



func _process(delta: float) -> void:
	## [Section] shooting
	if is_firing == true && on_weapon_cooldown == false:
		shooting()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN and event.pressed:
			chaning_camera_zoom(cam_step)
		elif event.button_index == BUTTON_WHEEL_UP and event.pressed:
			chaning_camera_zoom(cam_step * -1)
		## [Section] shooting
		if event.is_action_pressed("shoot"):
			is_firing = true
		if event.is_action_released("shoot"):
			is_firing = false


func chaning_camera_zoom(var _zoom: float):
	# [improve] make more like exponential function instead of linear function
	cam_actual_zoom += _zoom
	cam_actual_zoom = clamp (cam_actual_zoom, 0.1, 10.0)
	Cam.zoom = Vector2(cam_actual_zoom, cam_actual_zoom)

func get_shoot_state():
	print("[ERROR] This section should be overrided by ship script")
	breakpoint
	

func shooting():
	on_weapon_cooldown = true
	cooldown.start()
	GameServer.send_unreliable_attack(get_shoot_state())


func set_acceleration_factor():
	var acc_factor_coef = LocalData.terminal_multipleS["Acceleration"]
	acceleration = base_acceleration * acc_factor_coef


func define_movement(delta):
	is_accelerate = false
	if Input.is_action_pressed("up") and not(Input.is_action_pressed("down")):
		is_accelerate = true
		velocity += Vector2(acceleration, 0).rotated(actual_rotation)
	if Input.is_action_pressed("down") and actual_speed != 0:
		var x_slow = (velocity.x / actual_speed) * current_slow 
		var y_slow = (velocity.y / actual_speed) * current_slow 
		if actual_speed < acceleration:
			actual_speed = 0
			velocity = Vector2(0, 0)
			x_slow = 0
			y_slow = 0
		if abs(velocity.x) < abs(x_slow) || abs(velocity.y) < abs(y_slow):
			 current_slow = slow_speed
		current_slow += slow_speed * 0.05
		velocity -= Vector2(x_slow, y_slow)
	if Input.is_action_just_released("down"):
		current_slow = slow_speed
	velocity = move_and_slide(velocity)

func define_rotation(delta):
	rotation_dir = Input.get_axis("left", "right")
	actual_rotation += deg2rad(rotation_dir * rotation_speed * delta)
	if actual_rotation >= PI:
		actual_rotation = -PI
	elif actual_rotation <= -PI:
		actual_rotation = PI

func applay_rotation(_actual_rotation):
	pivot.rotation = _actual_rotation
	collision_polygon.rotation = _actual_rotation

func map_edge(edges = "S"):
	var x = position.x
	var y = position.y
	# teleportative background
	if edges == "T":
		if x > map_limit_right:
			position.x = map_limit_left + 1
		if x < map_limit_left:
			position.x = map_limit_right - 1
		if y > map_limit_bottom:
			position.y = map_limit_top + 1
		if y < map_limit_top:
			position.y = map_limit_bottom - 1
	# solid background
	if edges == "S":
		if x > map_limit_right:
			position.x = map_limit_right
			velocity.x = 0
		if x < map_limit_left:
			position.x = map_limit_left
			velocity.x = 0
		if y > map_limit_bottom:
			position.y = map_limit_bottom
			velocity.y = 0
		if y < map_limit_top:
			position.y = map_limit_top
			velocity.y = 0


func _cooldown():
	on_weapon_cooldown = false


func define_player_position_and_time() -> Dictionary:
	# [improve] It is possible to have knowladge about rotation_dir and is_accelerate without sending it
	var player_state: Dictionary = addition_to_player_state()
	player_state["T"] = GameServer.server_clock
	player_state["V"] = int(actual_speed)
	player_state["Location"] = {
		"P" : get_global_position(),
		"ACC" : is_accelerate,
		"R" : [actual_rotation, rotation_dir]
	}
	return player_state

func addition_to_player_state() -> Dictionary:
	return {}

func send_player_state(player_state: Dictionary):
	GameServer.send_player_state(player_state)

