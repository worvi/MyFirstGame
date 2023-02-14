extends Control

# UI states nodes
onready var login_screen = $Background/LoginScreen
onready var create_account_screen = $Background/CreateAccountScreen
onready var in_timer = $Timer
# login nodes
onready var username_input = $Background/LoginScreen/Username
onready var userpassword_input = $Background/LoginScreen/Password
onready var login_button = $Background/LoginScreen/LoginButton
onready var create_account_button = $Background/LoginScreen/CreateAccountButton
onready var ip_button = $Background/LoginScreen/PublicIPButton
# create account nodes
onready var create_username_input = $Background/CreateAccountScreen/Email
onready var create_userpassword_input = $Background/CreateAccountScreen/Password
onready var create_userpassword_repeat_input = $Background/CreateAccountScreen/RepeatedPassword
onready var confirm_button = $Background/CreateAccountScreen/ConfirmButton
onready var back_button = $Background/CreateAccountScreen/BackToLoginButton



func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	var err = $HTTPRequest.request("https://api.ipify.org/?format=json")
	if err != 0:
		var err_comm ="Ipify non connected: " + str(err)
		ip_button.set_text(err_comm)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	ip_button.set_text(str(json.result["ip"]))
	$HTTPRequest.queue_free()



func _on_LoginButton_pressed() -> void:
	if username_input.text == "" or userpassword_input.text == "":
		print("Please provide valid userID and password")
	else:
		all_buttons_disable(true)
		var username = username_input.get_text()
		var password = userpassword_input.get_text()
		print("Attempting to login")
		# [Test] Without athentication
		#Gateway.connect_to_server(username, password, false)
		GameServer.connect_to_server()
		in_timer.start()




func _on_CreateAccountButton_pressed() -> void:
	login_screen.hide()
	create_account_screen.show()

func _on_BackToLoginButton_pressed() -> void:
	login_screen.show()
	create_account_screen.hide()


func _on_ConfirmButton_pressed() -> void:
	if create_username_input.get_text() == "":
		print("Please provide a valid username")
	elif create_userpassword_input.get_text() == "":
		print("Please provide a valid password")
	elif create_userpassword_repeat_input.get_text() == "":
		print("Please repeat your password")
	elif create_userpassword_input.get_text().length() < 6:
		print("Password must contain at least 6 characters")
	elif create_userpassword_input.get_text() != create_userpassword_repeat_input.get_text():
		print("Passwords don't match")
	else:
		all_buttons_disable(true)
		var username = create_username_input.get_text()
		var password = create_userpassword_input.get_text()
		Gateway.connect_to_server(username, password, true)


func all_buttons_disable(var state: bool) -> void:
	confirm_button.disabled = state
	back_button.disabled = state
	login_button.disabled = state
	# [info] creating account not necessary
	#create_account_button.disabled = state



func _on_PublicIPButton_pressed():
	OS.set_clipboard(ip_button.text)


func _on_Timer_timeout():
	all_buttons_disable(false)
