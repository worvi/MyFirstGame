tool
extends Area2D

# [info] Synch it with client/server
enum TYPE {STR, ACC}
var data = {
	TYPE.STR:{
		"Radius": 200,
		"Power": 0.5,
		"PropertyName": "Damage"
	},
	TYPE.ACC:{
		"Radius": 300,
		"Power": 0.2,
		"PropertyName": "Acceleration"
	},
}

export(TYPE) var selection setget process_sel
var power = NAN
onready var in_col_shape = $CollisionShape2D
onready var _is_ready := true

var capture_time = 10 #seconds
var occuping_team #No one
var teams_on_point: Dictionary
var capturing_team = NAN

# [info] Works during editmode
func process_sel(_selection):
	#if is_inside_tree():
		selection = _selection
		power = data[_selection].Power
		var circle = CircleShape2D.new()
		if !_is_ready:
			yield(self, "ready")
		circle.radius = data[_selection].Radius
		$CollisionShape2D.set_shape(circle)
		#$Label.text = str(data[_selection].PropertyName)

#----------------GAME-MODE----------------

func _ready():
	process_sel(selection)
	$Timer.set_wait_time(capture_time)
	#self.set_process(false)

#func _process(delta):
	#$Label3.text = str($Timer.get_time_left())

func counter(team, entered):
	if entered:
		if !teams_on_point.has(team):
			teams_on_point.merge({team: 0})
		teams_on_point[team] += 1
	else:
		teams_on_point[team] -= 1
		if teams_on_point[team] <= 0:
			teams_on_point.erase(team)
	capture_logic()

func reset_timer():
	capturing_team = NAN
	$Timer.stop()
	$Timer.set_wait_time(capture_time)
	#self.set_process(false)
	#$Label3.text = str(capture_time)

func capture_logic():
	# [info] size mean number of teams on point
	if  teams_on_point.size()  < 1 \
			|| (teams_on_point.size() == 1 && occuping_team == teams_on_point.keys()[0]):
		reset_timer()
		return
	if teams_on_point.size() == 1:
		if capturing_team != teams_on_point.keys()[0]:
			capturing_team = teams_on_point.keys()[0]
			$Timer.start(capture_time)
		#self.set_process(true)
		$Timer.set_paused(false)
	if teams_on_point.size()  > 1:
		#self.set_process(false)
		$Timer.set_paused(true)

func get_parameters() -> Dictionary:
	var time_left = $Timer.get_time_left()
	var parameters = {
		"Name": name,
		"Location":{
			"P": position,
		},
		"PowerType": selection,
		"Power": power,
		"CaptureTime": capture_time,
		"OccupingTeam": occuping_team,
		"CapturingTeam": capturing_team,
		"TimeLeft": time_left,
	}
	return parameters

func _on_CapturePoint_body_entered(body):
	if body.is_in_group("Players"):
		counter(body.team, true)


func _on_CapturePoint_body_exited(body):
	if body.is_in_group("Players"): 
		counter(body.team, false)


func _on_Timer_timeout():
	reset_timer()
	# [info] reset stats of old holder
	
	if occuping_team != null:
		get_node("/root/GameServer/WorldMap/Upgrades").\
				increase_multiplier(occuping_team, data[selection].PropertyName, -(data[selection].Power))
	occuping_team = teams_on_point.keys()[0]
	get_node("/root/GameServer/WorldMap/Upgrades").\
			increase_multiplier(occuping_team, data[selection].PropertyName, data[selection].Power)
	get_node("/root/GameServer").send_cap_state(name, occuping_team)
	#$Label2.text = str(occuping_team)
