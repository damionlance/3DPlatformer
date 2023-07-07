extends Control

var last_active_menu_nodepath
var current_active_menu_nodepath
var current_active_menu


var camera_change_timer : Timer
var main_menu_cameras
@onready var main_menu = $"Control/MarginContainer"
var levels = []
var current_level
# Called when the node enters the scene tree for the first time.
func _ready():
	current_active_menu = $"Control"
	current_active_menu_nodepath = "res://scenes/ui/main menu.tscn"
	
	current_active_menu = load(current_active_menu_nodepath).instantiate()
	add_child(current_active_menu)
	var dir = DirAccess.open("res://scenes/levels")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				levels.append("res://scenes/levels/" + file_name)
			file_name = dir.get_next()
	
	if levels.size() == 0:
		get_tree().quit()
	
	current_level = load(levels[randi()%levels.size()-1])
	current_level = load("res://scenes/levels/temple.tscn")
	current_level = current_level.instantiate()
	add_child(current_level)
	current_level.is_level_preview = true
	camera_change_timer = Timer.new()
	add_child(camera_change_timer)
	camera_change_timer.wait_time = 15
	camera_change_timer.one_shot = true
	camera_change_timer.autostart = true
	main_menu_cameras = get_tree().get_nodes_in_group("Main Menu Cameras")

func _process(delta):
	if camera_change_timer.is_stopped():
		#main_menu_cameras[randi()%main_menu_cameras.size()].make_current()
		camera_change_timer.start()

func _on_options_pressed():
	current_active_menu.queue_free()
	last_active_menu_nodepath = current_active_menu_nodepath
	current_active_menu_nodepath = "res://scenes/ui/options.tscn"
	current_active_menu = load(current_active_menu_nodepath).instantiate()
	add_child(current_active_menu)

func main_menu_signals():
	$"Control/MarginContainer/Main Menu/Quit Game".pressed.connect(_on_quit_game_pressed)
	$"Control/MarginContainer/Main Menu/Options".pressed.connect(_on_options_pressed)
	$"Control/MarginContainer/Main Menu/New Game".pressed.connect(_on_new_game_pressed)

func _back():
	current_active_menu_nodepath = last_active_menu_nodepath
	current_active_menu.queue_free()
	current_active_menu = load(str(current_active_menu_nodepath)).instantiate()
	add_child(current_active_menu)
	current_active_menu._ready()

func _on_quit_game_pressed():
	get_tree().quit()

func _on_new_game_pressed():
	Global._delete_save()
	get_tree().change_scene_to_packed(load("res://scenes/levels/temple.tscn"))


func _on_level_picker_pressed():
	current_active_menu.queue_free()
	last_active_menu_nodepath = current_active_menu_nodepath
	current_active_menu_nodepath = "res://scenes/ui/level_select.tscn"
	current_active_menu = load(current_active_menu_nodepath).instantiate()
	add_child(current_active_menu)


func _on_load_game_pressed():
	get_tree().change_scene_to_packed(load("res://scenes/levels/temple.tscn"))
