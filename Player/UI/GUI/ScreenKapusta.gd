extends Control

onready var in_kapusta_label = $TextureRect/KapustaLabel

func _ready():
	actualize_kapusta()

func actualize_kapusta():
	in_kapusta_label.text = str(get_node(LocalData.KAPUSTA_PATH).current_kapusta())

