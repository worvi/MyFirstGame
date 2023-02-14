extends KinematicBody2D

# May be better to clear /hp stuff/ directly to HPBar node

var max_hp
var current_hp
var percentage_hp

var state
var type
var team = ["", "Enemy"]

onready var HPBar = $HPBar

func _ready() -> void:
	if state == "Dead":
		queue_free()

func health(health):
	if health != current_hp:
		current_hp = health
		HPBar.hpbar_update(current_hp)
		if health <= 0:
			on_death()

func move_enemy(new_position):
	set_position(new_position)


func on_death():
	queue_free()
