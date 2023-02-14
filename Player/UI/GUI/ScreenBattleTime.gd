extends Control

onready var TimeLabel = $TextureRect/TimeLabel

func actualize_time(time):
	TimeLabel.text = str(time)

