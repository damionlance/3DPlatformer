extends CharacterBody3D

@export var constants : PlayerPhysicsConstants

var movement_direction := Vector3.ZERO
var crouching := false
var speed := 0.0
var facing_direction := Vector3.ZERO

var sideways_friction := 10
var forwards_friction := 3

var current_jump := 0
var jump_reset_timer := Timer.new()

var delta_v := Vector3.ZERO

@onready var state_chart := $%StateChart
@onready var camera := $CameraPivot

#Raycasts
@onready var floor_alignment_raycast := $"%Floor Alignment Raycast"

func _ready():
	jump_reset_timer.connect("timeout", reset_jumps)
	add_child(jump_reset_timer)

func _physics_process(delta):
	input_polling()
	state_chart_expression_update()
	if is_on_floor():
		apply_friction(delta)
	velocity += delta_v * delta
	speed = Vector3(velocity.x, 0, velocity.y).length()
	move_and_slide()

func state_chart_expression_update():
	state_chart.set_expression_property("speed", speed)
	state_chart.set_expression_property("crouching", crouching)

func input_polling():
	var movement_input = Input.get_vector("Left", "Right", "Backward", "Forward")
	var forwards = camera.get_camera_basis().z
	forwards.y = 0
	forwards = forwards.normalized()
	forwards *= movement_input.y
	var right = camera.get_camera_basis().x * movement_input.x
	movement_direction = -forwards + right
	crouching = Input.is_action_pressed("DiveButton")
	

func grounded_movement_processing(delta):
	delta_v = movement_direction
	delta_v *= constants.running_acceleration
	delta_v.y = constants._fall_gravity * delta
	
	if Input.is_action_just_pressed("Jump"):
		state_chart.send_event("Jump")
		jump_reset_timer.stop()
	
	if not is_on_floor():
		state_chart.send_event("Fall")

func initial_jump_processing():
	match current_jump:
		0:
			velocity.y = constants._jump_strength
		1:
			velocity.y = constants._jump2_strength
		2:
			velocity.y = constants._jump3_strength
		

func normal_jump_processing(delta):
	delta_v = movement_direction
	delta_v *= constants.air_acceleration
	if velocity.y > 0:
		match current_jump:
			0:
				delta_v.y = constants._jump_gravity
			1:
				delta_v.y = constants._jump2_gravity
			2:
				delta_v.y = constants._jump3_gravity
	else:
		match current_jump:
			0:
				delta_v.y = constants._fall_gravity
			1:
				delta_v.y = constants._fall2_gravity
			2:
				delta_v.y = constants._fall3_gravity
	
	if velocity.y <= 0:
		state_chart.send_event("Fall")
	if is_on_floor():
		state_chart.send_event("Landed")
		current_jump += 1
		if current_jump == 3:
			current_jump = 0
		jump_reset_timer.start(delta * 7)

func reset_jumps():
	current_jump = 0

func apply_friction(delta):
	var forward_velocity = movement_direction
	forward_velocity *= movement_direction.dot(velocity)
	var lateral_velocity = velocity - forward_velocity
	
	lateral_velocity = lerp(lateral_velocity, Vector3.ZERO, sideways_friction * delta) 
	
	if forward_velocity.length() > constants.max_horizontal_velocity * delta or forward_velocity.dot(movement_direction) < 0:
		forward_velocity = lerp(forward_velocity, Vector3.ZERO, forwards_friction * delta)
	velocity = forward_velocity + lateral_velocity

func align_to_floor(delta):
	var floor_normal = floor_alignment_raycast.get_collision_normal()
	if floor_normal == Vector3.ZERO:
		return
	var xform = global_transform
	var new_y = floor_normal
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	global_transform = global_transform.interpolate_with(xform, 0.1)

func look_forward(delta):
	var normalized_direction = facing_direction.normalized()
	var lookdir = atan2(normalized_direction.x, normalized_direction.z)
	rotation.y = lookdir
	if movement_direction != Vector3.ZERO:
		facing_direction = movement_direction.normalized()


func _on_run_state_entered():
	state_chart.send_event("start_rotating")
