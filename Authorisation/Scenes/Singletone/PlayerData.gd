extends Node

var user_file = "user://PlayerIDs.dat"
var PlayerIDs = {}

func _ready() -> void:
	var open_file = File.new()
	open_file.open(user_file, File.READ)
	var PlayerIDs_date = open_file.get_var()
	open_file.close()
	PlayerIDs = PlayerIDs_date
#	print(PlayerIDs.keys())

func save_playerIDs():
	var save_file = File.new()
	save_file.open(user_file, File.WRITE)
	save_file.store_var(PlayerIDs)
	save_file.close()
