extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 42520
var cert = load("res://Resources/Certificate/X509_Certificate.crt")

var username
var password
var new_account = false

onready var login_screen = $"/root/Main/PopUp/LoginScreen"
onready var ip = get_node("/root/GameServer").ip


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func connect_to_server(_username, _password, _new_account):
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.set_dtls_enabled(true)
	network.set_dtls_verify_enabled(false) # Change it to true before release game!
	network.set_dtls_certificate(cert)
	username = _username
	password = _password
	new_account = _new_account
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")


func _on_connection_failed():
	print("Failed to connect to login server")
	print("Pop-up server offline or smth")
	login_screen.all_buttons_disable(false)

func _on_connection_succeeded():
	print("Succesfully to connect to login server")
	if new_account == true:
		request_create_account()
	else:
		request_login()


func request_login():
	print("Connecting to gateway to request login")
	rpc_id(1, "login_request", username, password.sha256_text())
	username = ""
	password = ""

remote func return_login_result(result, token):
	if result == true:
		GameServer.token = token
		GameServer.connect_to_server()
	else:
		print("Please provide correct username and password")
		login_screen.all_buttons_disable(false)
	network.disconnect("connection_failed", self, "_on_connection_failed")
	network.disconnect("connection_succeeded", self, "_on_connection_succeeded")


func request_create_account():
	print("Requesting new account")
	rpc_id(1, "create_account_request", username, password.sha256_text())
	username = ""
	password = ""

remote func return_create_account_request(result, message):
	print("Result recuved")
	if result == true:
		print("Account created")
		get_node("/root/Main/PopUp/LoginScreen")._on_BackToLoginButton_pressed()
	else:
		if message == 1:
			print("Couldn't created account")
		if message == 2:
			print("The username already exist")
	login_screen.all_buttons_disable(false)
	network.disconnect("connection_failed", self, "_on_connection_failed")
	network.disconnect("connection_succeeded", self, "_on_connection_succeeded")
