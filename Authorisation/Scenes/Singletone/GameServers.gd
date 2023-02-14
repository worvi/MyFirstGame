extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 42522
var max_players = 100
var gameserver_list = {}

func _ready() -> void:
	start_server()


func _process(delta: float) -> void:
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func start_server():
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("Game server HUB started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")


func _peer_connected(gameserver_id):
	print("Game server" + str(gameserver_id) + " connected")
	
	gameserver_list["Gameserver1"] = gameserver_id
	print(gameserver_list)


func _peer_disconnected(gameserver_id):
	print("Game server" + str(gameserver_id) + " disconnected")


func distribute_login_token(token, gameserver):
	var gameserver_peer_id = gameserver_list[gameserver]
	rpc_id(gameserver_peer_id, "recive_login_token", token)
