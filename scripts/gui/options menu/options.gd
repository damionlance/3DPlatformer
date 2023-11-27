extends Control


var new_settings = Dictionary()
var in_menu := false

var audioplayer = AudioStreamPlayer.new()
var audio_stream = load("res://assets/sounds/UI Noises/select button.ogg")
# Called when the node enters the scene tree for the first time.
func _ready():
	$"AnimationPlayer".play("slide_in")
	$"MarginContainer/Main Menu/Video".grab_focus()
	audioplayer.bus = "Sound Effects"
	audioplayer.set_stream(audio_stream)
	add_child(audioplayer)
	new_settings.clear()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if in_menu == false:
			_on_back_pressed()
		else:
			$"AnimationPlayer".play("slide_in")
			$"options container".visible = false
			$"options container/Panel/MarginContainer/Video".visible = false
			$"options container/Panel/MarginContainer/Audio".visible = false
			$"options container/Panel/MarginContainer/Controller Binds".visible = false
			$"MarginContainer/Main Menu/Video".grab_focus()
			in_menu = false

func apply_settings():
	Global.settings.merge(new_settings, true)
	Global.apply_settings()
	new_settings.clear()
	get_parent()._back()

func clear_settings():
	new_settings.clear()
	get_parent()._back()

func _on_back_pressed():
	audioplayer.play()
	if $"AnimationPlayer".current_animation != "slide_out":
		$"AnimationPlayer".play("slide_out")
	if new_settings.size() == 0:
		get_parent()._back()
	else:
		$MarginContainer.visible = false
		$"Apply Window".visible = true
		$"Apply Window/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/ApplyNo".grab_focus()

func _on_v_sync_button_toggled(button_pressed):
	new_settings["VSync"] = $"options container/Panel/MarginContainer/Video/GridContainer/Vsync Button".button_pressed

func _on_master_slider_value_changed(value):
	new_settings["Master Volume"] = $"options container/Panel/MarginContainer/Audio/GridContainer/Master Volume".value

func _on_music_slider_value_changed(value):
	new_settings["Music Volume"] = $"options container/Panel/MarginContainer/Audio/GridContainer/Music Volume".value

func _on_ambience_slider_value_changed(value):
	new_settings["Ambience Volume"] = $"options container/Panel/MarginContainer/Audio/GridContainer/Ambience Volume".value

func _on_sfx_slider_value_changed(value):
	new_settings["SFX Volume"] = $"options container/Panel/MarginContainer/Audio/GridContainer/SFX Volume".value


func _on_video_pressed():
	audioplayer.play()
	if $"AnimationPlayer".current_animation != "slide_out":
		$"AnimationPlayer".play("slide_out")
	$"options container".visible = true
	$"options container/Panel/MarginContainer/Video".visible = true
	in_menu = true


func _on_audio_pressed():
	audioplayer.play()
	if $"AnimationPlayer".current_animation != "slide_out":
		$"AnimationPlayer".play("slide_out")
	$"options container".visible = true
	$"options container/Panel/MarginContainer/Audio".visible = true
	in_menu = true


func _oncontroller_binds_pressed():
	audioplayer.play()
	if $"AnimationPlayer".current_animation != "slide_out":
		$"AnimationPlayer".play("slide_out")
	$"options container".visible = true
	$"options container/Panel/MarginContainer/Controller Binds".visible = true
	in_menu = true


func _on_msaa_item_selected(index):
	pass # Replace with function body.
