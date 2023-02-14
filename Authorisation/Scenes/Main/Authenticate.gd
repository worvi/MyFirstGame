extends Node

const DEFALUT_PORT = 42523
const MAX_SERVERS = 2
var network = NetworkedMultiplayerENet.new()


func _ready() -> void:
	start_server()

func start_server() -> void:
	network.create_server(DEFALUT_PORT, MAX_SERVERS)
	get_tree().set_network_peer(network)
	print("Authentication server started")
	
	network.connect("peer_connected", self, "_peer_conected")
	network.connect("peer_disconnected", self, "_peer_disconnected")


func _peer_conected(gateway_id) -> void:
	print("Gateway " + str(gateway_id) + " connected")
	
func _peer_disconnected(gateway_id) -> void:
	print("Gateway " + str(gateway_id) + " disconnected")

remote func authenticate_player(username, password, player_id):
	var gateway_id = get_tree().get_rpc_sender_id()
	var token
	var result
	print("Starting authentication")
#	print(PlayerData.PlayerIDs)
	if not PlayerData.PlayerIDs.has(username):
		result = false
	else:
		var retrived_salt = PlayerData.PlayerIDs[username]["Salt"]
		var hashed_password = generate_hashed_password(password, retrived_salt)
		if not PlayerData.PlayerIDs[username]["Password"] == hashed_password:
			result = false
		else:
			print("Succesful authentication")
			result = true
			
			randomize()
			token = str(randi()).sha256_text() + str(OS.get_unix_time())
			var gameserver = "Gameserver1"
			GameServers.distribute_login_token(token, gameserver)
	
	
	print("Authentication result send to gateway")
	rpc_id(gateway_id, "authentication_result", result, player_id, token)

remote func create_account(username, password, player_id):
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	var message
	if PlayerData.PlayerIDs.has(username):
		result = false
		message = 2
	else:
		result = true
		message = 3
		# FUCKING BAD PRACTICE OF SAVING PASS
		var salt = generate_salt()
		var hashed_password = generate_hashed_password(password, salt)
		PlayerData.PlayerIDs[username] = {"Password" : hashed_password, "Salt": salt}
		PlayerData.save_playerIDs()
	
	rpc_id(gateway_id, "create_account_result", result, player_id, message)

func generate_salt():
	randomize()
	var salt = str(randi()).sha256_text()
#	print("Salt: " + salt)
	return salt

func generate_hashed_password(password, salt):
	var hashed_password = password
	var rounds = pow(2, 18) + 3
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	return hashed_password
