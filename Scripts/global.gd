extends Node

var settings = Dictionary()

var BUTTON_NAMES : Dictionary

var stars = {"Atop the Mountain": false, "Down the Lazy River": false, "Pipes!": false}
var time_start

var last_input_device := "controller"

var WORLD_COLLECTIBLES : Dictionary
var has_saved := false

var save_semaphore
var mutex
var thread
var exit_thread

var left_stick_y_up = InputEventJoypadMotion.new()
var left_stick_y_down = InputEventJoypadMotion.new()
var left_stick_x_left = InputEventJoypadMotion.new()
var left_stick_x_right = InputEventJoypadMotion.new()
var right_stick_y_up = InputEventJoypadMotion.new()
var right_stick_y_down = InputEventJoypadMotion.new()
var right_stick_x_left = InputEventJoypadMotion.new()
var right_stick_x_right = InputEventJoypadMotion.new()

var callable
# Called when the node enters the scene tree for the first time.

func _ready():
	
	left_stick_y_down.axis = JOY_AXIS_LEFT_Y
	left_stick_y_down.device = 0
	left_stick_y_down.axis_value = 1.0
	left_stick_y_up.axis = JOY_AXIS_LEFT_Y
	left_stick_y_up.device = 0
	left_stick_y_up.axis_value = -1.0
	left_stick_x_left.axis = JOY_AXIS_LEFT_X
	left_stick_x_left.device = 0
	left_stick_x_left.axis_value = -1.0
	left_stick_x_right.axis = JOY_AXIS_LEFT_X
	left_stick_x_right.device = 0
	left_stick_x_right.axis_value = 1.0
	
	right_stick_y_down.axis = JOY_AXIS_RIGHT_Y
	right_stick_y_down.device = 0
	right_stick_y_down.axis_value = -1.0
	right_stick_y_up.axis = JOY_AXIS_RIGHT_Y
	right_stick_y_up.device = 0
	right_stick_y_up.axis_value = 1.0
	right_stick_x_left.axis = JOY_AXIS_RIGHT_X
	right_stick_x_left.device = 0
	right_stick_x_left.axis_value = 1.0
	right_stick_x_right.axis = JOY_AXIS_RIGHT_X
	right_stick_x_right.device = 0
	right_stick_x_right.axis_value = -1.0
	
	if not FileAccess.file_exists("user://settings.cfg"):
		default_settings()
	load_settings()
	apply_settings()
	
	setup_input_images("Xbox")
	
	mutex = Mutex.new()
	save_semaphore = Semaphore.new()
	exit_thread = false
	
	thread = Thread.new()
	callable = Callable(self, "_save_data")
	thread.start(callable)
	if FileAccess.file_exists("user://temp_save.res"):
		var data = FileAccess.open("user://temp_save.res", FileAccess.READ)
		var json = JSON.new()
		var parse_result = json.parse(data.get_line())
		if parse_result == OK:
			WORLD_COLLECTIBLES = json.data


func UPDATE_COLLECTIBLES(name, value):
	mutex.lock()
	WORLD_COLLECTIBLES[name] = value
	mutex.unlock()
	save_semaphore.post()

func _delete_save():
	if FileAccess.file_exists("user://temp_save.res"):
		OS.move_to_trash("user://temp_save.res")
	WORLD_COLLECTIBLES.clear()

func _save_data():
	while true:
		save_semaphore.wait()
		
		mutex.lock()
		var should_exit = exit_thread
		mutex.unlock()
		
		if should_exit:
			break
		
		mutex.lock()
		
		var save_game = FileAccess.open("user://temp_save.res", FileAccess.WRITE)
		var json = JSON.stringify(WORLD_COLLECTIBLES)
		save_game.store_line(json)
		
		mutex.unlock()

func _exit_tree():
	mutex.lock()
	exit_thread = true
	mutex.unlock()
	save_semaphore.post()
	
	thread.wait_to_finish()

func apply_settings():
	
	var settings_file = ConfigFile.new()
	match settings["Window Mode"]:
		"Windowed":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		"Borderless Fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		"Fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	match settings["Resolution"]:
		"1280x720":
			DisplayServer.window_set_size(Vector2i(1280,720))
		"1920x1080":
			DisplayServer.window_set_size(Vector2i(1920,1080))
		"2560x1440":
			DisplayServer.window_set_size(Vector2i(2560,1440))
		"3840x2160":
			DisplayServer.window_set_size(Vector2i(3840,2160))
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -100+settings["Master Volume"])
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -100+settings["Music Volume"])
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambient Sounds"), -100+settings["Ambience Volume"])
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), -100+settings["SFX Volume"])
	print(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sound Effects")))
	
	# Input Resets
	InputMap.action_erase_events("Forward")
	InputMap.action_erase_events("Backward")
	InputMap.action_erase_events("Left")
	InputMap.action_erase_events("Right")
	InputMap.action_erase_events("CameraUp")
	InputMap.action_erase_events("CameraDown")
	InputMap.action_erase_events("CameraLeft")
	InputMap.action_erase_events("CameraRight")
	InputMap.action_erase_events("DiveButton")
	InputMap.action_erase_events("Throw")
	InputMap.action_erase_events("Jump")
	InputMap.action_erase_events("Pause")
	
	# Keyboard Movement Inputs
	InputMap.action_add_event("Forward", settings["Keyboard Forward"])
	InputMap.action_add_event("Backward", settings["Keyboard Backward"])
	InputMap.action_add_event("Left", settings["Keyboard Left"])
	InputMap.action_add_event("Right", settings["Keyboard Right"])
	
	# Right Stick Input Definitions
	InputMap.action_add_event("Forward" if not settings["SouthPawMode"] else "CameraForward", left_stick_y_down if settings["LeftStickInvertY"] else left_stick_y_up)
	InputMap.action_add_event("Backward" if not settings["SouthPawMode"] else "CameraBackward",  left_stick_y_up if settings["LeftStickInvertY"] else left_stick_y_down)
	InputMap.action_add_event("Left" if not settings["SouthPawMode"] else "CameraLeft",  left_stick_x_right if settings["LeftStickInvertX"] else left_stick_x_left)
	InputMap.action_add_event("Right" if not settings["SouthPawMode"] else "CameraRight", left_stick_x_left if settings["LeftStickInvertX"] else left_stick_x_right)
	
	# Left Stick Input Definitions
	InputMap.action_add_event("Forward" if settings["SouthPawMode"] else "CameraUp", right_stick_y_down if settings["RightStickInvertY"] else right_stick_y_up)
	InputMap.action_add_event("Backward" if settings["SouthPawMode"] else "CameraDown", right_stick_y_up if settings["RightStickInvertY"] else right_stick_y_down)
	InputMap.action_add_event("Left" if settings["SouthPawMode"] else "CameraLeft",  right_stick_x_right if settings["RightStickInvertX"] else right_stick_x_left)
	InputMap.action_add_event("Right" if settings["SouthPawMode"] else "CameraRight", right_stick_x_left if settings["RightStickInvertX"] else right_stick_x_right)
	
	# Dive Inputs
	InputMap.action_add_event("DiveButton", settings["Keyboard Dive"])
	InputMap.action_add_event("DiveButton", settings["Controller Dive"])
	
	# Throw Inputs
	InputMap.action_add_event("Throw", settings["Keyboard Throw"])
	InputMap.action_add_event("Throw", settings["Controller Throw"])
	
	#Jump Inputs
	InputMap.action_add_event("Jump", settings["Keyboard Jump"])
	InputMap.action_add_event("Jump", settings["Controller Jump"])
	
	InputMap.action_add_event("Pause", settings["Keyboard Pause"])
	InputMap.action_add_event("Pause", settings["Controller Pause"])
	
	settings_file.set_value("Video", "Window Mode", settings["Window Mode"])
	settings_file.set_value("Video", "Resolution", settings["Resolution"])
	settings_file.set_value("Video", "VSync", settings["VSync"])
	
	settings_file.set_value("Audio", "Master Volume", settings["Master Volume"])
	settings_file.set_value("Audio", "Music Volume", settings["Music Volume"])
	settings_file.set_value("Audio", "Ambience Volume", settings["Ambience Volume"])
	settings_file.set_value("Audio", "SFX Volume", settings["SFX Volume"])
	
	settings_file.set_value("Gameplay", "Difficulty", settings["Difficulty"])
	
	settings_file.set_value("Keybinds", "Keyboard Forward", settings["Keyboard Forward"])
	settings_file.set_value("Keybinds", "Keyboard Backward", settings["Keyboard Backward"])
	settings_file.set_value("Keybinds", "Keyboard Left", settings["Keyboard Left"])
	settings_file.set_value("Keybinds", "Keyboard Right", settings["Keyboard Right"])
	settings_file.set_value("Keybinds", "Keyboard Jump", settings["Keyboard Jump"])
	settings_file.set_value("Keybinds", "Keyboard Dive", settings["Keyboard Dive"])
	settings_file.set_value("Keybinds", "Keyboard Throw", settings["Keyboard Throw"])
	settings_file.set_value("Keybinds", "Keyboard Pause", settings["Keyboard Pause"])
	settings_file.set_value("Keybinds", "Keyboard Place Spawn", settings["Keyboard Place Spawn"])
	settings_file.set_value("Keybinds", "Keyboard Respawn", settings["Keyboard Respawn"])
	settings_file.set_value("Keybinds", "Keyboard Camera Mode", settings["Keyboard Camera Mode"])
	
	settings_file.set_value("Keybinds", "Controller Jump", settings["Controller Jump"])
	settings_file.set_value("Keybinds", "Controller Dive", settings["Controller Dive"])
	settings_file.set_value("Keybinds", "Controller Throw", settings["Controller Throw"])
	settings_file.set_value("Keybinds", "Controller Pause", settings["Controller Pause"])
	settings_file.set_value("Keybinds", "Controller Place Spawn", settings["Controller Place Spawn"])
	settings_file.set_value("Keybinds", "Controller Respawn", settings["Controller Respawn"])
	settings_file.set_value("Keybinds", "Controller Camera Mode", settings["Controller Camera Mode"])
	
	settings_file.set_value("Keybinds", "SouthPawMode", settings["SouthPawMode"])
	settings_file.set_value("Keybinds", "LeftStickInvertY", settings["LeftStickInvertY"])
	settings_file.set_value("Keybinds", "LeftStickInvertX", settings["LeftStickInvertX"])
	settings_file.set_value("Keybinds", "RightStickInvertY", settings["RightStickInvertY"])
	settings_file.set_value("Keybinds", "RightStickInvertX", settings["RightStickInvertX"])
	
	settings_file.save("user://settings.cfg")
 
func load_settings():
	var settings_file = ConfigFile.new()
	var err = settings_file.load("user://settings.cfg")
	
	if err != OK:
		return
	
	settings["Window Mode"] = settings_file.get_value("Video", "Window Mode")
	settings["Resolution"] = settings_file.get_value("Video", "Resolution")
	settings["VSync"] = settings_file.get_value("Video", "VSync")
	
	settings["Master Volume"] = settings_file.get_value("Audio", "Master Volume")
	settings["Music Volume"] = settings_file.get_value("Audio", "Music Volume")
	settings["Ambience Volume"] = settings_file.get_value("Audio", "Ambience Volume")
	settings["SFX Volume"] = settings_file.get_value("Audio", "SFX Volume")
	
	settings["Difficulty"] = settings_file.get_value("Gameplay", "Difficulty")
	
	settings["Keyboard Forward"] = settings_file.get_value("Keybinds", "Keyboard Forward")
	settings["Keyboard Backward"] = settings_file.get_value("Keybinds", "Keyboard Backward")
	settings["Keyboard Left"] = settings_file.get_value("Keybinds", "Keyboard Left")
	settings["Keyboard Right"] = settings_file.get_value("Keybinds", "Keyboard Right")
	settings["Keyboard Jump"] = settings_file.get_value("Keybinds", "Keyboard Jump")
	settings["Keyboard Dive"] = settings_file.get_value("Keybinds", "Keyboard Dive")
	settings["Keyboard Throw"] = settings_file.get_value("Keybinds", "Keyboard Throw")
	settings["Keyboard Pause"] = settings_file.get_value("Keybinds", "Keyboard Pause")
	settings["Keyboard Place Spawn"] = settings_file.get_value("Keybinds", "Keyboard Place Spawn")
	settings["Keyboard Respawn"] = settings_file.get_value("Keybinds", "Keyboard Respawn")
	settings["Keyboard Camera Mode"] = settings_file.get_value("Keybinds", "Keyboard Camera Mode")
	
	settings["Controller Jump"] = settings_file.get_value("Keybinds", "Controller Jump")
	settings["Controller Dive"] = settings_file.get_value("Keybinds", "Controller Dive")
	settings["Controller Throw"] = settings_file.get_value("Keybinds", "Controller Throw")
	settings["Controller Pause"] = settings_file.get_value("Keybinds", "Controller Pause")
	settings["Controller Place Spawn"] = settings_file.get_value("Keybinds", "Controller Place Spawn")
	settings["Controller Respawn"] = settings_file.get_value("Keybinds", "Controller Respawn")
	settings["Controller Camera Mode"] = settings_file.get_value("Keybinds", "Controller Camera Mode")
	
	settings["SouthPawMode"] = settings_file.get_value("Keybinds", "SouthPawMode")
	settings["LeftStickInvertY"] = settings_file.get_value("Keybinds", "LeftStickInvertY")
	settings["LeftStickInvertX"] = settings_file.get_value("Keybinds", "LeftStickInvertX")
	settings["RightStickInvertY"] = settings_file.get_value("Keybinds", "RightStickInvertY")
	settings["RightStickInvertX"] = settings_file.get_value("Keybinds", "RightStickInvertX")
	
	settings["Camera Mode"] = settings_file.get_value("Keybinds", "Camera Mode")
	

func default_settings():
	var settings_file = ConfigFile.new()
	
	settings_file.set_value("Video", "Window Mode", "Windowed")
	settings_file.set_value("Video", "Resolution", "1280x720")
	settings_file.set_value("Video", "VSync", false)
	
	settings_file.set_value("Audio", "Master Volume", 100)
	settings_file.set_value("Audio", "Music Volume", 100)
	settings_file.set_value("Audio", "Ambience Volume", 100)
	settings_file.set_value("Audio", "SFX Volume", 100)
	
	settings_file.set_value("Gameplay", "Difficulty", 2)
	
	settings_file.set_value("Keybinds", "Keyboard Forward", InputMap.action_get_events("Forward")[0])
	settings_file.set_value("Keybinds", "Keyboard Backward", InputMap.action_get_events("Backward")[0])
	settings_file.set_value("Keybinds", "Keyboard Left", InputMap.action_get_events("Left")[0])
	settings_file.set_value("Keybinds", "Keyboard Right", InputMap.action_get_events("Right")[0])
	settings_file.set_value("Keybinds", "Keyboard Jump", InputMap.action_get_events("Jump")[0])
	settings_file.set_value("Keybinds", "Keyboard Dive", InputMap.action_get_events("DiveButton")[0])
	settings_file.set_value("Keybinds", "Keyboard Throw", InputMap.action_get_events("Throw")[0])
	settings_file.set_value("Keybinds", "Keyboard Pause", InputMap.action_get_events("Pause")[0])
	settings_file.set_value("Keybinds", "Keyboard Place Spawn", InputMap.action_get_events("Place Spawn")[0])
	settings_file.set_value("Keybinds", "Keyboard Respawn", InputMap.action_get_events("Respawn")[0])
	settings_file.set_value("Keybinds", "Keyboard Camera Mode", InputMap.action_get_events("Camera Mode")[0])
	
	settings_file.set_value("Keybinds", "Controller Jump", InputMap.action_get_events("Jump")[1])
	settings_file.set_value("Keybinds", "Controller Throw", InputMap.action_get_events("Throw")[1])
	settings_file.set_value("Keybinds", "Controller Dive", InputMap.action_get_events("DiveButton")[1])
	settings_file.set_value("Keybinds", "Controller Pause", InputMap.action_get_events("Pause")[1])
	settings_file.set_value("Keybinds", "Controller Place Spawn", InputMap.action_get_events("Place Spawn")[1])
	settings_file.set_value("Keybinds", "Controller Respawn", InputMap.action_get_events("Respawn")[1])
	settings_file.set_value("Keybinds", "Controller Camera Mode", InputMap.action_get_events("Camera Mode")[1])
	
	settings_file.set_value("Keybinds", "SouthPawMode", false)
	settings_file.set_value("Keybinds", "LeftStickInvertY", false)
	settings_file.set_value("Keybinds", "LeftStickInvertX", false)
	settings_file.set_value("Keybinds", "RightStickInvertY", false)
	settings_file.set_value("Keybinds", "RightStickInvertX", false)
	
	settings_file.save("user://settings.cfg")

func setup_input_images(device):
	var dir = DirAccess.open("res://assets/textures/input prompts")
	var image_names
	var apath = "res://assets/textures/input prompts/active input/"
	match device:
		"Keyboard":
			pass
		"Xbox":
			var xpath = "res://assets/textures/input prompts/Xbox/"
			dir.copy(xpath + InputMap.action_get_events("Jump")[1].as_text() + ".png", apath + "Jump.png")
			dir.copy(xpath + InputMap.action_get_events("Throw")[1].as_text() + ".png", apath + "Throw.png")
			dir.copy(xpath + InputMap.action_get_events("DiveButton")[1].as_text() + ".png", apath + "Dive.png")
			dir.copy(xpath + InputMap.action_get_events("Pause")[1].as_text() + ".png", apath + "Pause.png")
			dir.copy(xpath + InputMap.action_get_events("Place Spawn")[1].as_text() + ".png", apath + "Place Spawn.png")
			dir.copy(xpath + InputMap.action_get_events("Respawn")[1].as_text() + ".png", apath + "Respawn.png")
			dir.copy(xpath + InputMap.action_get_events("Camera Mode")[1].as_text() + ".png", apath + "Camera Mode.png")
	
