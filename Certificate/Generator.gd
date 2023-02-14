extends Node
#X509
var cert_filname = "X509_Certificate.crt"
var key_filename = "Key.key"

onready var cert_path = "user://Certificate/" + cert_filname
onready var key_path = "user://Certificate/" + key_filename


var CN = "MultiplayerGameTest"
var O = "NoOrganistaionName"
var C = "PL"
var not_before = "20211015000000"
var not_after = "20221015235900"

func _ready() -> void:
	var directory = Directory.new()
	if directory.dir_exists("user://Certificate"):
		pass
	else:
		directory.make_dir("user://Certificate")
	create_cert()
	print("Certificate Created")

func create_cert():
	var CNOC = "CN=" + CN + ",O=" + O + ",C=" + C
	var crypto = Crypto.new()
	var crypto_key = crypto.generate_rsa(4096)
	var cert = crypto.generate_self_signed_certificate(crypto_key, CNOC, not_before, not_after)
	cert.save(cert_path)
	crypto_key.save(key_path)
