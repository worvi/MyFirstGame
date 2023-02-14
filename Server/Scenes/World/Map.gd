extends Node

func get_all_capture_points_data() -> Array:
	var array: Array
	for point in get_tree().get_nodes_in_group("CapturePoint"):
		array.append(point.get_parameters())
	return array
