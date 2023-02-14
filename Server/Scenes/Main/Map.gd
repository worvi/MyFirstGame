extends Node

var enemy_id_counter = 1
var enemy_maximum = 0
var enemy_types = ["Bot_ship"]
var enemy_spawn_points = [Vector2(50, 50), Vector2(-50, 50), Vector2(0, -50)]
var open_locations = [0,1,2]
var occupied_locations = {}
var enemy_list = {}


#func _ready() -> void:
#	var timer = Timer.new()
#	timer.wait_time = 3
#	timer.autostart = true
#	timer.connect("timeout", self, "Spawn_enemy")
#	self.add_child(timer)

func Spawn_enemy() -> void:
	if enemy_list.size() >= enemy_maximum:
		pass
	else:
		randomize()
		var type = enemy_types[randi() % enemy_types.size()]
		var rng_location_index = randi() % open_locations.size()
		var location = enemy_spawn_points[open_locations[rng_location_index]]
		occupied_locations[enemy_id_counter] = open_locations[rng_location_index]
		open_locations.remove(rng_location_index)
		enemy_list[enemy_id_counter] = {"EnemyType": type, "EnemyLocation": location, "EnemyHealth": 500, "EnemyMaxHealth": 500, "EnemyState": "Idle", "time_out": 1}
		get_parent().get_node("WorldMap").spawn_enemy(enemy_id_counter, location)
		enemy_id_counter += 1
	for enemy in enemy_list.keys():
		if enemy_list[enemy]["EnemyState"] == "Dead":
			if enemy_list[enemy]["time_out"] == 0:
				enemy_list.erase(enemy)
			else:
				enemy_list[enemy]["time_out"] = enemy_list[enemy]["time_out"] - 1

func npc_hit(enemy_id, damage):
	if enemy_list[enemy_id]["EnemyHealth"] <=0:
		pass
	else:
		enemy_list[enemy_id]["EnemyHealth"] = enemy_list[enemy_id]["EnemyHealth"] - damage
		if enemy_list[enemy_id]["EnemyHealth"] <= 0:
			get_node("/root/GameServer/WorldMap/" + str(enemy_id)).queue_free()
			enemy_list[enemy_id]["EnemyState"] = "Dead"
			open_locations.append(occupied_locations[enemy_id])
			occupied_locations.erase(enemy_id)
