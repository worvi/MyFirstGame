extends Node

const BEGINNING_TIME = 5
var player_id
var player_info
var current_terraship_winning
var current_bid: int = 0
var terra_ships_in_bidding: Array
var bidding_starting_iterator = 0
var bidding_id = 0


onready var in_timer = $BidTime


func begin_bidding(initialization_info, terra_ships_ids):
	randomize()
	var _owner = terra_ships_ids[bidding_starting_iterator]
	bidding_id = randi()
	player_id = initialization_info.ID
	player_info = initialization_info
	current_bid = 0
	terra_ships_in_bidding = terra_ships_ids
	bidding_starting_iterator += 1
	bidding_starting_iterator %= 2
	current_terraship_winning = _owner
	for terra_id in terra_ships_in_bidding:
		get_node("/root/GameServer").send_bid(terra_id, bidding_id, player_info, current_bid, _owner)
	# [info] Last part is same player id due to have blue color and non interaction
	get_node("/root/GameServer").send_bid(player_id, bidding_id, player_info, current_bid, player_id)
	in_timer.start(BEGINNING_TIME)

func new_bid (this_terra_id, _bidding_id, amount):
	if !verification(this_terra_id, _bidding_id, amount):
		return
	if in_timer.get_time_left() < 3.0:
		in_timer.start(3.0)
	current_bid += amount
	current_terraship_winning = this_terra_id
	for terra_id in terra_ships_in_bidding:
		get_node("/root/GameServer").send_bid(terra_id, bidding_id, player_info, current_bid, this_terra_id)
	# [info] Last part is same player id due to have blue color and non interaction
	get_node("/root/GameServer").send_bid(player_id, bidding_id, player_info, current_bid, player_id)

func verification(this_terra_id, _bidding_id, amount) -> bool:
	if !terra_ships_in_bidding.has(this_terra_id):
		print("[BIDDING]: ",this_terra_id, " wanted to bid but its not in bidding")
		return false
	if bidding_id != _bidding_id:
		print("[BIDDING]: Bad bid id")
		return false
	if amount != 10 and amount != 100:
		print("[BIDDING]: Diffenrent bid amount: ", amount)
		return false
	if  !get_node("../KapustaControlNode").is_transaction_possible(this_terra_id, amount + current_bid):
		print("[BIDDING]: Too much kapusta amount for player: ", amount + current_bid, " when he has: ", 
				get_node("../KapustaControlNode").get_player_spended_kapusta(this_terra_id) + get_node("../KapustaControlNode").current_base_kapusta())
		return false
	return true

func _on_BidTime_timeout():
	bidding_id = 0
	get_parent().initalizate_player_from_auction(current_terraship_winning, current_bid)
	get_node("../KapustaControlNode").add_spended_kapusta(current_terraship_winning, current_bid)
	get_node("../KapustaControlNode").add_recived_kapusta(player_id, current_bid)
	print("[BIDDING]: End of bidding")

func bidding_player_disconnected(id_disconnected_player):
	for terra_id in terra_ships_in_bidding:
		if terra_id != id_disconnected_player:
			get_node("/root/GameServer").send_bid(terra_id, bidding_id, player_info, 0, 0)
	if player_id != id_disconnected_player and player_id != null:
		get_node("/root/GameServer").send_bid(player_id, bidding_id, player_info, 0, 0)
	end_bid()

func end_bid():
	in_timer.stop()
	current_bid = 0
	bidding_id = 0
	player_id = null
