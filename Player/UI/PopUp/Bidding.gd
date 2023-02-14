extends Control

const BEGINNING_TIME = 5
var bidding_id = 0
var bidding_pot = 0
var bid_owner
onready var in_time_left = $Background/BiddingScreen/BidsButtons2/TimeLeft
onready var in_ship_name = $Background/BiddingScreen/ShipName
onready var in_actual_price = $Background/BiddingScreen/ActualPrice
onready var in_button_10 = $Background/BiddingScreen/BidsButtons/Ten
onready var in_button_100 = $Background/BiddingScreen/BidsButtons/Hundred

onready var in_timer = $BidTime


func _ready():
	set_process(false)
	in_button_10.disabled = true
	in_button_100.disabled = true

func _process(delta):
	in_time_left.text = String(in_timer.get_time_left()).left(4)


func bid(_bidding_id, player, _bid_amount, _owner):
	if _owner == 0:
		in_timer.stop()
		_on_BidTime_timeout()
		print("Auction has been stopped!")
		return
	bidding_id = _bidding_id
	bid_owner = _owner
	in_actual_price.text = String(_bid_amount)
	in_ship_name.text = player.ST
	if _owner == get_tree().get_network_unique_id():
		in_actual_price.set_self_modulate(Color("00abf4"))
		in_ship_name.set_self_modulate(Color("00abf4")) # blue
	else: 
		in_actual_price.set_self_modulate(Color("c83232"))
		in_ship_name.set_self_modulate(Color("c83232")) # red / enemy
		in_button_10.disabled = false
		in_button_100.disabled = false
		# [info] returning money
		get_node("/root/Main/KapustaControlNode").add_recived_kapusta(bidding_pot)
	if !self.is_visible():
		in_timer.start(BEGINNING_TIME)
		set_process(true)
		self.show()
	if in_timer.get_time_left() < 3.0:
		in_timer.start(3.0)
	in_button_10.text = str(_bid_amount + 10)
	in_button_100.text = str(_bid_amount + 100)
	# [info] It is counting for next getting back money- so it has to be after returning money
	bidding_pot = _bid_amount


func _on_Ten_pressed():
	proceed_cliced_button(10)
func _on_Hundred_pressed():
	proceed_cliced_button(100)


func proceed_cliced_button(amount):
	in_button_10.disabled = true
	in_button_100.disabled = true
	if get_node("/root/Main/KapustaControlNode").check_is_enough_kapusta(bidding_pot + amount):
		bidding_pot += amount
		get_node("/root/Main/KapustaControlNode").add_spended_kapusta(bidding_pot)
		GameServer.send_bid(bidding_id, amount)
	else:
		in_button_10.disabled = false
		in_button_100.disabled = false


func _on_BidTime_timeout():
	in_button_10.disabled = true
	in_button_100.disabled = true
	bidding_pot = 0
	# [info] If we loose then we get back bidded money
#	if !bid_owner == get_tree().get_network_unique_id():
	# [info] Player who was 'item' on bidding gets money
	set_process(false)
	self.hide()
