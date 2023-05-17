extends Control

var levels = []
var level_names = []

func _ready():
	var dir = DirAccess.open("res://scenes/levels")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				level_names.append(file_name.trim_suffix(".tscn"))
				levels.append("res://scenes/levels/" + file_name)
			file_name = dir.get_next()
	
	if levels.size() == 0:
		get_tree().quit()
	
	for i in levels.size():
		var new_level_card = load("res://scenes/ui/level_card.tscn").instantiate()
		$"MarginContainer/VBoxContainer/Panel/VSplitContainer/MarginContainer/ScrollContainer/HSplitContainer".add_child(new_level_card)
		new_level_card.set_up_card(levels[i], level_names[i], "res://assets/textures/coinsprite.png")
	$"MarginContainer/VBoxContainer/Panel/VSplitContainer/MarginContainer/ScrollContainer/HSplitContainer".get_child(0).get_child(0).grab_focus()
