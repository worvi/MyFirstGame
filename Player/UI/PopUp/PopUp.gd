extends CanvasLayer

var logged = false
onready var n_game_menu = $GameMenu
onready var in_login_screen = $LoginScreen
onready var in_select_team = $SelectTeam

func _ready() -> void:
	n_game_menu.hide()
	in_login_screen.show()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("GameMenu") && logged:
		if (n_game_menu.is_visible()):
			n_game_menu.hide()
		else:
			n_game_menu.show()


func go_to_select_team():
	in_login_screen.queue_free()
	in_select_team.show()
