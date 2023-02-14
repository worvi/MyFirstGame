extends Area2D

# [info] Synch it with client/server
enum TYPE {STR, ACC}
var data = {
	TYPE.STR:{
		"Radius": 200,
		"Power": 1.2,
		"DisplayName": "Strength"
	},
	TYPE.ACC:{
		"Radius": 300,
		"Power": 1.2,
		"DisplayName": "Acceleration"
	},
}

export(Color, RGB) var enemy_color
export(Color, RGB) var ally_color

onready var color = {
	"Ally": ally_color,
	"Enemy": enemy_color
}


var power_type
var power
var capture_time
var teams_on_point: Dictionary
var capturing_team
var capturing_team_relevant
var occuping_team
var occuping_team_relevant
var time_left



func _init():
	self.hide()

func init(cap_data):
	name = cap_data.Name
	position = cap_data.Location.P
	power_type = cap_data.PowerType
	power = cap_data.Power
	capture_time = cap_data.CaptureTime
	occuping_team = cap_data.OccupingTeam
	capturing_team = cap_data.CapturingTeam
	time_left = cap_data.TimeLeft
	$CollisionShape2D.set_scale(Vector2(data[power_type].Radius / 10, data[power_type].Radius / 10))


func _ready():
	self.show()
	$Timer.set_wait_time(capture_time)
	self.set_process(false)
	if occuping_team != null:
		point_captured(occuping_team)
	# [info] When you join and point is capturing
	# [improve] So when point captured 1st time then time_left & capturing_team are useless
	if time_left != 0:
		capturing_team_relevant = get_node("/root/Main").determine_team_relevance(capturing_team)
		$Timer.start(time_left)
		$CollisionShape2D/TextureProgress.set_value(-($Timer.get_time_left() - capture_time) * 10 -1)
		$CollisionShape2D/TextureProgress.set_tint_progress(color[capturing_team_relevant])


func _process(delta):
	$CollisionShape2D/TextureProgress.set_value(-($Timer.get_time_left() - capture_time) * 10 -1)

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
	capturing_team_relevant = null
	$Timer.stop()
	$Timer.set_wait_time(capture_time)
	self.set_process(false)
	$CollisionShape2D/TextureProgress.set_value(0)

func capture_logic():
	# [info] size mean number of teams on point
	if  teams_on_point.size()  < 1 \
				|| (teams_on_point.size() == 1 && occuping_team_relevant == teams_on_point.keys()[0]):
		reset_timer()
		return
	if teams_on_point.size() == 1:
		if capturing_team_relevant != teams_on_point.keys()[0]:
			$CollisionShape2D/TextureProgress.set_tint_progress(color[teams_on_point.keys()[0]])
			capturing_team_relevant = teams_on_point.keys()[0]
			$Timer.start(capture_time)
		self.set_process(true)
		$Timer.set_paused(false)
	if teams_on_point.size()  > 1:
		self.set_process(false)
		$Timer.set_paused(true)


func _on_Area2D_body_entered(body):
	if body.is_in_group("Players"):
		counter(body.team.Relevant, true)


func _on_Area2D_body_exited(body):
	if body.is_in_group("Players"): 
		counter(body.team.Relevant, false)


func point_captured(_occuping_team):# Change this to server based (0-99% of fulfilment
	reset_timer()
	occuping_team_relevant = get_node("/root/Main").determine_team_relevance(_occuping_team)
	$CollisionShape2D/TextureProgress.set_tint_under(color[occuping_team_relevant])


func _on_Timer_timeout():
	$Timer.stop()
