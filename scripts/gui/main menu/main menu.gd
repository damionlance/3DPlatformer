extends Control


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	$"MarginContainer/Main Menu/New Game".grab_focus()
	get_parent().main_menu_signals()
