extends Node2D

onready var tscn_cap = preload("res://Map/CapturePoint/CapturePoint.tscn")

func spawn_capture_points(capture_points_data):
	for cap_data in capture_points_data:
		var inst_cap = tscn_cap.instance()
		inst_cap.init(cap_data)
		add_child(inst_cap)
