extends MarginContainer

# MiniMap
export var zoom = 1 setget set_zoom
var grid_scale
var markers = {}

var terra_ship_sprite = preload("res://assets/PNG/ufoBlue.png")
var normal_ship_sprite = preload("res://assets/PNG/playerShip1_blue.png")

onready var grid = $Margin/Grid
onready var player_marker = $Margin/PlayerMarker
onready var ally_marker = $Margin/AllyMarker
onready var enemy_marker = $Margin/EnemyMarker
onready var icons = {"Ally": ally_marker, "Enemy": enemy_marker}

func _enter_tree():
	if get_node("/root/Main").my_ship_type != "TerraShip":
		self.hide()
	else:
		self.show()

func _ready() -> void:
	player_marker.position = $Margin.rect_size / 2
	grid_scale = grid.rect_size / (get_viewport().size * zoom)


func _process(_delta: float) -> void:
	minimap()


# [improve] is it faster when in old version (when ship was connected with player_template, or now???
func minimap():
	var player = get_node(LocalData.PLAYER_PATH)
	player_marker.rotation = player.actual_rotation + PI * 0.5
	for ship in markers:
		var real_ship = get_node_or_null("/root/Main/PlayersWorld/" + str(ship))
		if real_ship != null:
			var obj_position = (real_ship.position - player.position) * grid_scale + grid.rect_size * 0.5
			if grid.get_rect().has_point(obj_position + grid.rect_position):
				markers[ship]["Obj"].scale = Vector2(1 * 1/zoom, 1 * 1/zoom)
			else:
				markers[ship]["Obj"].scale = Vector2(0.7 * 1/zoom, 0.7 * 1/zoom)
			obj_position.x = clamp(obj_position.x, 0, grid.rect_size.x)
			obj_position.y = clamp(obj_position.y, 0, grid.rect_size.y)
			markers[ship]["Obj"].position = obj_position
		else:
			markers[ship]["Obj"].queue_free()
			markers.erase(ship)


func add_ship(ship_name: String, relevant_team: String):
	var new_marker = icons[relevant_team].duplicate()
	new_marker.name = ship_name
	markers[ship_name] = {"Obj": new_marker}
	grid.add_child(new_marker, true)
	new_marker.show()


func reload_teams():
	# [improve] instead deleting all markers just properly change its visualities
	# [improve] im almost sure that it can be done better
	if get_node("/root/Main").my_ship_type == "TerraShip":
		player_marker.set_texture(terra_ship_sprite)
	else:
		player_marker.set_texture(normal_ship_sprite)
	for child in grid.get_children():
		child.queue_free()
	markers.clear()
	for ship in get_node("/root/Main/PlayersWorld").get_children():
		if ship.name != "Player":
			var relevant_team = ship.team["Relevant"]
			var ship_name = ship.name
			add_ship(ship_name, relevant_team)


func set_zoom(value):
	zoom = clamp(value, 0.6, 4)
	grid_scale = grid.rect_size / (get_viewport().size * zoom)
	player_marker.scale = Vector2(0.4/zoom, 0.4/zoom)


func _on_MiniMap_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_UP:
			self.zoom -= 0.2
		if event.button_index == BUTTON_WHEEL_DOWN:
			self.zoom += 0.2
