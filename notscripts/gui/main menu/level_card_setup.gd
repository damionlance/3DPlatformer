extends MarginContainer


func set_up_card(path, name, texture):
	$"Level Card".level_path = path
	$"Level Card/MarginContainer/VSplitContainer/Level Name".text = name
	$"Level Card/MarginContainer/VSplitContainer/Level ThumbNail".texture = load(texture)
