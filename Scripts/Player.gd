extends KinematicBody

onready var player_camera = $Camera

onready var player_model = $Root

var camera_angle
var Velocity := Vector3(0.0, 0.0, 0.0)
var InputDirection := Vector3(0,0,0)
var ClippingVector := Vector3(0.0, -1.0, 0.0)
var Gravity := Vector3(0.0, -200, 0.0)

func _ready():
	pass # Replace with function body.

func _process(delta):
	if Velocity != Vector3.ZERO:
		player_model.look_at(global_transform.origin - Vector3(Velocity.x, 0, Velocity.z), Vector3.UP)
	camera_angle = player_camera.transform.basis.get_euler().y
	Velocity += Gravity * delta
	
	move_and_slide_with_snap(Velocity, ClippingVector, Vector3(0,1,0), false)
	
	# Reset input detection
	if !Input.is_action_pressed("Forward"):
		InputDirection.x = 0
	if !Input.is_action_pressed("Left"):
		InputDirection.z = 0
	if !Input.is_action_pressed("Right"):
		InputDirection.z = 0
	if !Input.is_action_pressed("Backward"):
		InputDirection.x = 0
	
	if is_on_floor():
		
		# Sliding when stopping
		Velocity *= .9
		
		# Input detection
		#	TO-DO:
		#		Support controller!
		if Input.is_action_pressed("Forward"):
			InputDirection.x += 1
		if Input.is_action_pressed("Left"):
			InputDirection.z -= 1
		if Input.is_action_pressed("Right"):
			InputDirection.z += 1
		if Input.is_action_pressed("Backward"):
			InputDirection.x -= 1
		
		InputDirection = InputDirection.rotated(Vector3.UP, camera_angle + PI/2 )
		
		Velocity += InputDirection * 50 * delta
		
		Velocity.y = 0
		ClippingVector=Vector3(0.0, -1.0, 0.0)
		if Input.is_action_just_pressed("ui_up"):
			Velocity.y += 50
			ClippingVector=Vector3(0.0, 0.0, 0.0)
	else:
		ClippingVector=Vector3(0.0, 0.0, 0.0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
