extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 42520
var max_players = 100
var cert = load("res://Certificate/X509_Certificate.crt")
var key = load("res://Certificate/Key.key")


func _ready() -> void:
	start_server()


func _process(delta: float) -> void:
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func start_server():
	network.set_dtls_enabled(true)
	network.set_dtls_certificate(cert)
	network.set_dtls_key(key)
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("Gateway server started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")


func _peer_connected(player_id):
	print("User" + str(player_id) + " connected")


func _peer_disconnected(player_id):
	print("User" + str(player_id) + " disconnected")


remote func login_request(username, password):
	print("login request recived")
	var player_id = custom_multiplayer.get_rpc_sender_id()
	Authenticate.authenticate_player(username, password, player_id)

func return_login_request(result, player_id, token):
	rpc_id(player_id, "return_login_result", result, token)
	network.disconnect_peer(player_id)


remote func create_account_request(username, password):
	var player_id = custom_multiplayer.get_rpc_sender_id()
	var valid_request = true
	if username == "" || password == "" || password.length() < 6:
		valid_request = false
	
	if valid_request == false:
		return_create_account_request(valid_request, player_id, 1)
	else:
		Authenticate.create_account(username.to_lower(), password, player_id)

func return_create_account_request(result, player_id, message):
	rpc_id(player_id, "return_create_account_request", result, message)
	# 1 = faild to create; 2 = existing username; 3 = welcome
	network.disconnect_peer(player_id)
