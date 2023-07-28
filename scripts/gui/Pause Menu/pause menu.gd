extends Control

var last_active_menu_nodepath
var current_active_menu_nodepath
var current_active_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	$"AnimationPlayer".play("menu slide in")
	$"MarginContainer/Main Menu/Resume".grab_focus()
	main_menu_signals()
	pass # Replace with function body.

func _on_options_pressed():
	last_active_menu_nodepath = current_active_menu_nodepath
	current_active_menu_nodepath = "res://scenes/ui/options.tscn"
	current_active_menu = load(current_active_menu_nodepath).instantiate()
	add_child(current_active_menu)
	pass # Replace with function body.
	
func _back():
	main_menu_signals()
	$"MarginContainer/Main Menu/Resume".grab_focus()
	current_active_menu.queue_free()

func _on_quit_game_pressed():
	Global._save_data()
	get_tree().change_scene_to_packed(load("res://scenes/ui/title screen.tscn"))
	pass # Replace with function body.


func _on_resume_pressed():
	if $"AnimationPlayer".current_animation != "menu slide out":
		$"AnimationPlayer".play("menu slide out")
	get_parent().find_child("CameraPivot").halt_input = false
	get_tree().paused = false
	get_viewport().gui_get_focus_owner().release_focus()


func main_menu_signals():
	$"MarginContainer/Main Menu/Save and Quit".pressed.connect(_on_save_and_quit_pressed)
	$"MarginContainer/Main Menu/Options".pressed.connect(_on_options_pressed)
	$"MarginContainer/Main Menu/Resume".pressed.connect(_on_resume_pressed)



func _on_animation_player_animation_finished(anim_name):
	if anim_name == "menu slide out":
		queue_free()


func _on_save_and_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_packed(load("res://scenes/ui/title screen.tscn"))


func _on_reload_pressed():
	Global._delete_save()
	get_tree().reload_current_scene()
	get_tree().paused = false
