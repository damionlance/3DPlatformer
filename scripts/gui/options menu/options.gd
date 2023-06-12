extends Control

var tabs = ["MarginContainer/VBoxContainer/TabContainer/Video",
			"MarginContainer/VBoxContainer/TabContainer/Audio",
			"MarginContainer/VBoxContainer/TabContainer/Gameplay",
			"MarginContainer/VBoxContainer/TabContainer/Keybinds"]

var keybinds_tabs = ["MarginContainer/VBoxContainer/TabContainer/Keybinds/TabContainer/Keyboard",
					"MarginContainer/VBoxContainer/TabContainer/Keybinds/TabContainer/Controller"]

var current_tab = 0
var keybinds_tab = 0

var new_settings = Dictionary()

# Called when the node enters the scene tree for the first time.
func _ready():
	$"MarginContainer/VBoxContainer/TabContainer".grab_focus()

func _process(delta):
	if $"MarginContainer/VBoxContainer/TabContainer".has_focus():
		var input_occurred = false
		var previous_tab = current_tab
		if Input.is_action_just_pressed("ui_left"):
			current_tab -= 1
			input_occurred = true
		elif Input.is_action_just_pressed("ui_right"):
			current_tab += 1
			input_occurred = true
		elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_down"):
			if current_tab != 3:
				get_node(tabs[current_tab]+"/ScrollContainer/MarginContainer/Settings").get_child(1).grab_focus()
			else:
				get_node("MarginContainer/VBoxContainer/TabContainer/Keybinds/TabContainer").grab_focus()
		if input_occurred:
			if current_tab == 4:
				current_tab = 0
			elif current_tab == -1:
				current_tab = 3
			$"MarginContainer/VBoxContainer/TabContainer".current_tab = current_tab
	elif $"MarginContainer/VBoxContainer/TabContainer/Keybinds/TabContainer".has_focus():
		var input_occurred = false
		var previous_tab = current_tab
		if Input.is_action_just_pressed("ui_left"):
			input_occurred = true
		elif Input.is_action_just_pressed("ui_right"):
			input_occurred = true
		elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_down"):
			get_node(keybinds_tabs[keybinds_tab]+"/ScrollContainer/MarginContainer/Settings").get_child(1).grab_focus()
			print(get_node(keybinds_tabs[keybinds_tab]+"/ScrollContainer/MarginContainer/Settings").get_child(1).name)
		if input_occurred:
			keybinds_tab = 1 - keybinds_tab
			$"MarginContainer/VBoxContainer/TabContainer/Keybinds/TabContainer".current_tab = keybinds_tab
		

func apply_settings():
	Global.settings.merge(new_settings, true)
	Global.apply_settings()

func _on_back_pressed():
	print(new_settings)
	if new_settings.size() == 0:
		get_parent()._back()
	else:
		$MarginContainer.visible = false
		$"Apply Window".visible = true
		$"Apply Window/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/ApplyNo".grab_focus()
	
	pass # Replace with function body.

func _on_apply_no_pressed():
	get_parent()._back()

func _on_apply_yes_pressed():
	apply_settings()
	get_parent()._back()

func _on_mode_select_item_selected(index):
	new_settings["Window Mode"] = $"MarginContainer/VBoxContainer/TabContainer/Video/ScrollContainer/MarginContainer/Settings/Mode Select".get_item_text(index)

func _on_resolution_select_item_selected(index):
	new_settings["Resolution"] = $"MarginContainer/VBoxContainer/TabContainer/Video/ScrollContainer/MarginContainer/Settings/Resolution Select".get_item_text(index)

func _on_v_sync_button_toggled(button_pressed):
	new_settings["VSync"] = $"MarginContainer/VBoxContainer/TabContainer/Video/ScrollContainer/MarginContainer/Settings/VSync Button".button_pressed

func _on_master_slider_value_changed(value):
	new_settings["Master Volume"] = $"MarginContainer/VBoxContainer/TabContainer/Audio/ScrollContainer/MarginContainer/Settings/Master Slider".value

func _on_music_slider_value_changed(value):
	new_settings["Music Volume"] = $"MarginContainer/VBoxContainer/TabContainer/Audio/ScrollContainer/MarginContainer/Settings/Music Slider".value

func _on_ambience_slider_value_changed(value):
	new_settings["Ambience Volume"] = $"MarginContainer/VBoxContainer/TabContainer/Audio/ScrollContainer/MarginContainer/Settings/Ambience Slider".value

func _on_sfx_slider_value_changed(value):
	new_settings["SFX Volume"] = $"MarginContainer/VBoxContainer/TabContainer/Audio/ScrollContainer/MarginContainer/Settings/SFX Slider".value
