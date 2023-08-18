extends SubViewport

var screenshots = []

@export var enable := false

var allow_break = false
var thread

var recording = false
var current_camera = 0
var number_of_cameras = 0


func _ready():
	if not enable:
		get_parent().queue_free()
	else:
		number_of_cameras = get_child_count()
		get_child(0).current = true

func _process(_delta):
	if not allow_break and not Input.is_joy_button_pressed(0,JOY_BUTTON_RIGHT_SHOULDER) and not Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_LEFT) and Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT) < .2 and not Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_RIGHT):
		allow_break = true
	elif (Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_RIGHT) or Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT) > .5) and allow_break:
		get_child(current_camera).current = false
		if current_camera + 1 == number_of_cameras:
			current_camera = 0
		else: current_camera += 1
		get_child(current_camera).current = true
		allow_break = false
	elif Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_LEFT) and allow_break:
		get_child(current_camera).current = false
		if current_camera - 1 < 0:
			current_camera = number_of_cameras - 1
		else: current_camera -= 1
		get_child(current_camera).current = true
		allow_break = false
	elif Input.is_joy_button_pressed(0,JOY_BUTTON_RIGHT_SHOULDER) and not recording and allow_break:
		allow_break = false
		recording = true
		#get_parent().position.y = 1920
		size = Vector2(1920, 1080)
		thread = Thread.new()
		thread.start(record_screen)
		print("recording")

func record_screen():
	while true:
		if allow_break and Input.is_joy_button_pressed(0,JOY_BUTTON_RIGHT_SHOULDER):
			print("stop")
			#get_parent().position.y = 0
			size = Vector2(500, 300)
			allow_break = false
			recording = false
			return
			
		await RenderingServer.frame_post_draw
		var image = get_texture().get_image()
		screenshots.append(image)

func _exit_tree():
	if enable == false:
		return
	var thread0 = Thread.new()
	var thread1 = Thread.new()
	var thread2 = Thread.new()
	var thread3 = Thread.new()
	thread0.start(_save_picture.bind(0))
	thread1.start(_save_picture.bind(1))
	thread2.start(_save_picture.bind(2))
	thread3.start(_save_picture.bind(3))
	await thread0.wait_to_finish()
	await thread1.wait_to_finish()
	await thread2.wait_to_finish()
	await thread3.wait_to_finish()

func _save_picture(start):
	
	for i in screenshots.size() - 1:
		if start + (4 * i) > screenshots.size() - 1:
			return
		screenshots[start + (4 * i)].save_png("user://recording/" + str(start + (4 * i)) + ".png")
		print((i / screenshots.size() - 1) * 100, "%")
