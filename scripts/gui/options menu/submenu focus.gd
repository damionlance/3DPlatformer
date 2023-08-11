extends VBoxContainer

func _ready():
	connect("visibility_changed", _is_visible)

func _is_visible():
	if visible:
		find_child("GridContainer").get_child(1).grab_focus()
