extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 42522

onready var gameserver = get_node("/root/GameServer")

func _ready() -> void:
	connect_to_server()


func _process(_delta: float) -> void:
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func connect_to_server():
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")


func _on_connection_failed():
	print("Failed to connect to game server hub")


func _on_connection_succeeded():
	print("Succesfully to connect to game server hub")


remote func recive_login_token(token):
	gameserver.expected_tokens.append(token)
