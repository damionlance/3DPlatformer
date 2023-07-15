extends SubViewport

var screenshots = []

var allow_break = false
var thread

var recording = false
var current_camera = 0
var number_of_cameras = 0


func _ready():
	number_of_cameras = get_child_count()
	get_child(0).current = true

func _process(delta):
	if Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_RIGHT) and allow_break and not recording:
		get_child(current_camera).current = false
		if current_camera + 1 == number_of_cameras:
			current_camera = 0
		else: current_camera += 1
		get_child(current_camera).current = true
		allow_break = false
	elif Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_LEFT) and allow_break and not recording:
		get_child(current_camera).current = false
		if current_camera - 1 < 0:
			current_camera = number_of_cameras - 1
		else: current_camera -= 1
		get_child(current_camera).current = true
		allow_break = false
	elif Input.is_joy_button_pressed(0,JOY_BUTTON_RIGHT_SHOULDER) and not recording and allow_break:
		allow_break = false
		recording = true
		get_parent().get_parent().position.y = 1920
		get_parent().custom_minimum_size = Vector2(1920, 1080)
		thread = Thread.new()
		thread.start(record_screen)
		print("recording")
	elif not allow_break and not Input.is_joy_button_pressed(0,JOY_BUTTON_RIGHT_SHOULDER) and not Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_LEFT) and not Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_RIGHT) and not recording:
		allow_break = true

func record_screen():
	while true:
		if allow_break and Input.is_joy_button_pressed(0,JOY_BUTTON_RIGHT_SHOULDER):
			print("stop")
			get_parent().get_parent().position.y = 0
			get_parent().custom_minimum_size = Vector2(500, 300)
			allow_break = false
			recording = false
			return
		elif not Input.is_joy_button_pressed(0,JOY_BUTTON_RIGHT_SHOULDER):
			allow_break = true
			
		await RenderingServer.frame_post_draw
		var image = get_texture().get_image()
		screenshots.append(image)

func _exit_tree():
	var thread0 = Thread.new()
	var thread1 = Thread.new()
	var thread2 = Thread.new()
	var thread3 = Thread.new()
	thread0.start(_save_picture.bind(0))
	thread1.start(_save_picture.bind(1))
	thread2.start(_save_picture.bind(2))
	thread3.start(_save_picture.bind(3))
	await thread3.wait_to_finish()

func _save_picture(start):
	
	for i in screenshots.size() - 1:
		if start + (4 * i) > screenshots.size() - 1:
			return
		screenshots[start + (4 * i)].save_png("user://recording/" + str(start + (4 * i)) + ".png")
