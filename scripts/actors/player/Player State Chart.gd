extends CharacterBody3D

@export var constants : PlayerPhysicsConstants

var movement_direction := Vector3.ZERO
var speed := 0.0
var facing_direction := Vector3.ZERO

var sideways_friction := 10
var forwards_friction := 3

var current_jump := -1
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
	state_chart.set_expression_property("current_jump", current_jump)

func input_polling():
	var movement_input = Input.get_vector("Left", "Right", "Backward", "Forward")
	var forwards = camera.get_camera_basis().z
	forwards.y = 0
	forwards = forwards.normalized()
	forwards *= movement_input.y
	var right = camera.get_camera_basis().x * movement_input.x
	movement_direction = -forwards + right

func grounded_movement_processing(delta):
	delta_v = movement_direction
	delta_v *= constants.running_acceleration
	delta_v.y = constants._fall_gravity * delta
	
	if not is_on_floor():
		state_chart.send_event("Fall")

func check_for_jump(delta : float) -> void:
	if Input.is_action_just_pressed("Jump"):
		state_chart.send_event("Jump")
		jump_reset_timer.stop()

func initial_jump_processing():
	state_chart.send_event("stop_rotating")
	velocity.y = constants.jump_strength[current_jump]
	match current_jump:
		3:
			movement_direction = movement_direction.normalized() * constants.max_horizontal_velocity
			velocity = Vector3(movement_direction.x, constants.jump_strength[current_jump], movement_direction.z)
			look_forward(0.0166)

func normal_jump_processing(delta : float):
	delta_v = movement_direction
	delta_v *= constants.air_acceleration
	if velocity.y > 0:
		delta_v.y = constants.jump_gravity[current_jump]
	else:
		delta_v.y = constants.fall_gravity[current_jump]
	
	if Input.is_action_just_pressed("DiveButton"):
		state_chart.send_event("Dive")
	
	if velocity.y <= 0:
		state_chart.send_event("Fall")
	
	if is_on_floor():
		state_chart.send_event("Landed")

func set_jump(jump_index : int) -> void:
	current_jump = jump_index

func increment_jump() -> void:
	current_jump += 1
	if current_jump == 3:
		current_jump = 0

func start_jump_reset_timer() -> void:
	jump_reset_timer.start(0.0166 * 7)

func reset_jumps() -> void:
	current_jump = -1

func apply_friction(delta) -> void:
	var forward_velocity = movement_direction
	forward_velocity *= movement_direction.dot(velocity)
	var lateral_velocity = velocity - forward_velocity
	
	lateral_velocity = lerp(lateral_velocity, Vector3.ZERO, sideways_friction * delta) 
	
	if forward_velocity.length() > constants.max_horizontal_velocity * delta or forward_velocity.dot(movement_direction) < 0:
		forward_velocity = lerp(forward_velocity, Vector3.ZERO, forwards_friction * delta)
	velocity = forward_velocity + lateral_velocity

func align_to_floor(delta) -> void:
	var floor_normal = floor_alignment_raycast.get_collision_normal()
	if floor_normal == Vector3.ZERO:
		return
	var xform = global_transform
	var new_y = floor_normal
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	global_transform = global_transform.interpolate_with(xform, 0.1)

func look_forward(delta) -> void:
	var normalized_direction = movement_direction.normalized()
	var lookdir = atan2(normalized_direction.x, normalized_direction.z)
	rotation.y = lookdir
	if movement_direction != Vector3.ZERO:
		facing_direction = movement_direction.normalized()
