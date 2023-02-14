extends RigidBody2D

var projectile_speed = 2000
var life_time = 3

func _init():
	var timer = Timer.new()
	timer.name = "Cooldown"
	timer.autostart = true
	timer.wait_time = life_time
	timer.connect("timeout", self, "self_destruct")
	add_child(timer)

func _ready() -> void:
	apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(rotation))

func self_destruct():
	queue_free()

# [improve] sometimes shoot is not hide properly
func _on_Laser_body_entered(_body: Node) -> void:
	$CollisionShape2D.set_deferred("disable", true)
	self.set_deferred("contact_monitor", false)
	self.hide()
