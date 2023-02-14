extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 42523


func _ready() -> void:
	connect_to_server()
	

func connect_to_server():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")


func _on_connection_failed():
	print("Failed to connect to authentication server")


func _on_connection_succeeded():
	print("Succesfully to connect to authentication server")


func authenticate_player(username, password, player_id):
	print("Sending out authentication request")
	rpc_id(1, "authenticate_player", username, password, player_id)

remote func authentication_result(result, player_id, token):
	print("Results recived and reploying to player login request")
	Gateway.return_login_request(result, player_id, token)


func create_account(username, password, player_id):
	print("sending out create account request")
	rpc_id(1, "create_account", username, password, player_id)

remote func create_account_result(result, player_id, message):
	print("result recuved and reploying to player create account request")
	Gateway.return_create_account_request(result, player_id, message)
