extends Node

var last_world_state = 0
var world_state_buffer = []
# [improve] Think about good player multi information place
var my_team_id: int
var my_ship_type: String

onready var GUI = preload("res://UI/GUI/GUI.tscn")
onready var PlayersWorld = $PlayersWorld


func determine_team_relevance(team_number) -> String:
	if my_team_id == team_number:
		return "Ally"
	else:
		return "Enemy"



func self_player_initialization(player_information, battle_time):
	my_team_id = player_information.T
	my_ship_type = player_information.ST
	create_self_player(player_information)
	add_child(GUI.instance())
	print("battle time: ",battle_time)
	get_node("KapustaControlNode").begining_time_of_battle = int(battle_time * 0.001)
	get_node("GUI").set_begining_time_of_battle(battle_time)
	if my_team_id != null:
		set_teams_for_existance_players(my_team_id)
		# [improve] it is executing first time, so its generating icons 2 times
		get_node("/root/Main/GUI/MiniMap").reload_teams()
	else:
		print("I don't have a team? Wth?")

func create_self_player(player_information):
	var player = LocalData.SHIPS_DICT_TSCN[my_ship_type].instance()
	player.init(player_information)
	add_child_below_node(PlayersWorld, player)


func spawn_new_players_from_information(players_information: Dictionary):
	for player_id in players_information:
		if !PlayersWorld.has_node(str(player_id)):
			var new_player = LocalData.SHIPS_DICT_TSCN[players_information[player_id].ST].instance()
			new_player.set_script(LocalData.PLAYER_TEMPLATE_GD[players_information[player_id].ST])
			new_player.init(player_id, players_information[player_id], my_team_id)
			PlayersWorld.add_child(new_player)
			var MiniMap = get_node_or_null("/root/Main/GUI/MiniMap")
			if  MiniMap:
				MiniMap.add_ship(str(player_id), new_player.team.Relevant)
			else:
				print("[Main] Please delete me and repair!!!")
			if players_information[player_id].T == my_team_id:
				var TeamView = get_node_or_null("/root/Main/GUI/TeamView")
				var dict = {
						"ShipType": players_information[player_id].ST, 
						"Task": "Waiting for task"
				}
				TeamView.add_ship(str(player_id), dict)
			


func set_teams_for_existance_players(this_player_team):
	for player_temp in PlayersWorld.get_children():
		if player_temp.has_method("set_team_properites"):
			if player_temp.team.ID == this_player_team:
				player_temp.set_team_properites("Ally")
				player_temp.team["Relevant"] = "Ally"
				player_temp.set_texture()
			else:
				player_temp.set_team_properites("Enemy")
				player_temp.team["Relevant"] = "Enemy"
				player_temp.set_texture()


func despawn_player_template(player_id):
	# [improve] It may crash when player disconnect and he hasn't spawned yet
	# [improve] Player may be despawned bcs client don't recive information about
	# [buggy] Morover client may recive slower package about player who was despawned and it will crash game (or can it?)
	print("Ship: ", player_id, " has been despawned")
	if PlayersWorld.has_node(str(player_id)):
		get_node("./PlayersWorld/" + str(player_id)).on_death()
		var TeamView = get_node_or_null("/root/Main/GUI/TeamView")
		if TeamView != null:
			TeamView.delete_ship(player_id)

func despawn_all_templated_players():
	# [improve] It may crash when player disconnect and he hasn't spawned yet
	# [improve] Player may be despawned bcs client don't recive information about
	# [buggy] Morover client may recive slower package about player who was despawned and it will crash game (or can it?)
	for player_id in PlayersWorld.get_children():
		player_id.on_death()

func update_world_state(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)



func _physics_process(_delta: float) -> void:
	var render_time = GameServer.client_clock
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2]["T"]:
			world_state_buffer.remove(0)
		if world_state_buffer.size() > 2:
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			for player in world_state_buffer[2].keys():
				if str(player) == "T":
					continue
				if str(player) == "Enemies":
					continue
				if player == get_tree().get_network_unique_id():
					if(world_state_buffer[2][player].has("HP")):
						var player_node = get_node_or_null(LocalData.PLAYER_PATH)
						if  player_node != null:
							player_node.change_hp(world_state_buffer[2][player].HP)
					continue
				if PlayersWorld.has_node(str(player)) and world_state_buffer[1].has(player):
					PlayersWorld.get_node(str(player)).manage_template_state(world_state_buffer[1][player], world_state_buffer[2][player], interpolation_factor)
		elif render_time > world_state_buffer[1]["T"]:
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.0
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if str(player) == "Enemies":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[0].has(player):
					continue
				if get_node("/root/Main/PlayersWorld/").has_node(str(player)):
					var position_delta = world_state_buffer[1][player]["Location"]["P"] - world_state_buffer[0][player]["Location"]["P"]
					var new_position = world_state_buffer[1][player]["Location"]["P"] + position_delta * extrapolation_factor
					get_node("/root/Main/PlayersWorld/" + str(player)).set_position(new_position)



# Not used
func spawn_new_enemy(enemy_id, enemy_dict) -> void:
	if enemy_dict["EnemyState"] != "Dead":
		var new_enemy = LocalData.ENEMY_SPAWN_TSCN.instance()
		new_enemy.position = enemy_dict["EnemyLocation"]
		new_enemy.max_hp = enemy_dict["EnemyMaxHealth"]
		new_enemy.current_hp = enemy_dict["EnemyHealth"]
		new_enemy.type = enemy_dict["EnemyType"]
		new_enemy.state = enemy_dict["EnemyState"]
		new_enemy.name = str(enemy_id)
		add_child(new_enemy, true)
		GUI.add_ship(new_enemy)
