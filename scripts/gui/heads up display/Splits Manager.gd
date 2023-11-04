extends MarginContainer

var current_run = Dictionary()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$"VBoxContainer/Current Time".text = $"Run Timer"._get_current_time()

func _add_split(split_name):
	var time = $"Run Timer".time
	var time_string = $"Run Timer"._get_current_time()
	var new_split = RichTextLabel.new()
	
	var time_difference
	var minutes
	var seconds
	var milliseconds
	
	current_run[split_name] = time_string
	current_run[split_name + "_time"] = time
	
	if split_name == "Game Over":
		if Global.SPEEDRUN_SPLITS["BEST RUN"].has(split_name):
			if Global.SPEEDRUN_SPLITS["BEST RUN"][split_name+"_time"] > time:
				Global.SPEEDRUN_SPLITS["BEST RUN"] = current_run
		else:
			Global.SPEEDRUN_SPLITS["BEST RUN"] = current_run
	
	if Global.SPEEDRUN_SPLITS["BEST RUN"].has(split_name):
		if Global.SPEEDRUN_SPLITS["BEST RUN"][split_name + "_time"] > time:
			var temp = Global.SPEEDRUN_SPLITS["BEST RUN"][split_name + "_time"] - time
			var var_sign = "+" if temp > 0 else "-"
			var text = var_sign
			minutes = abs(temp / 60)
			if minutes >= 1:
				text += "%02d:" % [minutes]
			seconds = abs(fmod(temp, 60))
			if seconds >= 1:
				text += "%02d" % [seconds]
			milliseconds = abs(fmod(temp, 1) * 100)
			if milliseconds > 0:
				text += ".%02d" % [milliseconds]
			time_difference = "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
			new_split.text = "[color=Green]" + split_name + ": " + time_string + "\t\t" + text
	if Global.SPEEDRUN_SPLITS["BEST INDIVIDUAL SPLITS"].has(split_name):
		if Global.SPEEDRUN_SPLITS["BEST INDIVIDUAL SPLITS"][split_name + "_time"] > time:
			var temp = Global.SPEEDRUN_SPLITS["BEST INDIVIDUAL SPLITS"][split_name + "_time"] - time
			var var_sign = "+" if temp > 0 else "-"
			var text = var_sign
			minutes = abs(temp / 60)
			if minutes >= 1:
				text += "%02d:" % [minutes]
			seconds = abs(fmod(temp, 60))
			if seconds >= 1:
				text += "%02d" % [seconds]
			milliseconds = abs(fmod(temp, 1) * 100)
			if milliseconds > 0:
				text += ".%02d" % [milliseconds]
			time_difference = "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
			new_split.text = "[color=Yellow]" + split_name + ": " + time_string + "\t\t" + text
			Global.SPEEDRUN_SPLITS["BEST INDIVIDUAL SPLITS"][split_name] = time_string
			Global.SPEEDRUN_SPLITS["BEST INDIVIDUAL SPLITS"][split_name + "_time"] = time
		elif new_split.text == "":
			var temp = Global.SPEEDRUN_SPLITS["BEST INDIVIDUAL SPLITS"][split_name + "_time"] - time
			var var_sign = "+" if temp > 0 else "-"
			var text = var_sign
			minutes = abs(temp / 60)
			if minutes >= 1:
				text += "%02d:" % [minutes]
			seconds = abs(fmod(temp, 60))
			if seconds >= 1:
				text += "%02d" % [seconds]
			milliseconds = abs(fmod(temp, 1) * 100)
			if milliseconds > 0:
				text += ".%02d" % [milliseconds]
			time_difference = "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
			new_split.text = "[color=Red]" + split_name + ": " + time_string + "\t\t" + text
	elif not Global.SPEEDRUN_SPLITS["BEST INDIVIDUAL SPLITS"].has(split_name):
		Global.SPEEDRUN_SPLITS["BEST INDIVIDUAL SPLITS"][split_name] = time_string
		Global.SPEEDRUN_SPLITS["BEST INDIVIDUAL SPLITS"][split_name + "_time"] = time
		new_split.text = "[color=Yellow]" + split_name + ": " + time_string
	
	new_split.theme = load("res://assets/UI Themes/default dialogue theme.tres")
	new_split.push_font_size(12)
	new_split.autowrap_mode = TextServer.AUTOWRAP_OFF
	new_split.bbcode_enabled = true
	new_split.fit_content = true
	$"VBoxContainer/Splits".add_child(new_split)
	var new_splits_height = 0
	for split in $"VBoxContainer/Splits".get_children():
		new_splits_height = split.custom_minimum_size.y
	$"VBoxContainer/Splits".custom_minimum_size.y = new_splits_height
