extends CanvasLayer

var progres_color
var percentage_hp

onready var max_hp = get_parent().max_hp
onready var current_hp_started: float = get_parent().current_hp
onready var Pivot = $Pivot
onready var health_over = $Pivot/HealthOver
onready var health_under = $Pivot/HealthUnder
onready var speed = $Pivot/Speed

func _ready() -> void:
	hpbar_update(current_hp_started)

func _process(_delta):
	Pivot.position = get_parent().position
	

func hpbar_update(current_hp):
	percentage_hp  = int (float(current_hp) * 100 / max_hp)
	health_over.value = percentage_hp
	progres_color = Color((100-float(percentage_hp))/100, float(percentage_hp)/80, 0.184314)
	health_over.set_tint_progress(progres_color)

func velocity_update(current_velocity):
	speed.text = current_velocity
