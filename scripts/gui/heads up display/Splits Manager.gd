extends MarginContainer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"VBoxContainer/Current Time".text = $"Run Timer"._get_current_time()

func _add_split(split_name):
	var new_split = RichTextLabel.new()
	new_split.theme = load("res://assets/UI Themes/default dialogue theme.tres")
	new_split.text = "[color=Yellow]" + split_name + ": " + $"Run Timer"._get_current_time()
	new_split.autowrap_mode = TextServer.AUTOWRAP_OFF
	new_split.bbcode_enabled = true
	new_split.fit_content = true
	$"VBoxContainer/Splits".add_child(new_split)
	var new_splits_height = 0
	for split in $"VBoxContainer/Splits".get_children():
		new_splits_height = split.custom_minimum_size.y
	$"VBoxContainer/Splits".custom_minimum_size.y = new_splits_height
