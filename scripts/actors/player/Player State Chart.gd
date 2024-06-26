extends CharacterBody3D

@export var constants : PlayerPhysicsConstants

var movement_direction := Vector3.ZERO
var speed := 0.0
var facing_direction := Vector3.ZERO

var sideways_friction := 10
var forwards_friction := 3

var current_jump := -1
var jump_reset_timer := Timer.new()

# Flags
var pivot:= false

var delta_v := Vector3.ZERO

var joystick_input_buffer : Array[Vector2] = []

@onready var state_chart := $%StateChart
@onready var camera := $CameraPivot
@onready var animation_tree := $AnimationTree
@onready var wall_jump_raycasts := $"%Wall Jump Raycasts"

#Raycasts
@onready var floor_alignment_raycast := $"%Floor Alignment Raycast"

func _ready():
	jump_reset_timer.connect("timeout", reset_jumps)
	add_child(jump_reset_timer)
	
	joystick_input_buffer.resize(5)

func _physics_process(delta):
	velocity += delta_v * delta
	speed = Vector3(velocity.x, 0, velocity.z).length()
	move_and_slide()
	
	input_polling()
	state_chart_expression_update()
	delta_v = Vector3.ZERO

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

func wall_climb_processing(delta) -> void:
	if not wall_jump_raycasts.check_wall_group("climbable zone"):
		return
	var wall_normal = wall_jump_raycasts.get_average_wall_normal()
	var wall_distance = wall_jump_raycasts.get_average_wall_distance()
	
	var wall_sideways = wall_normal.cross(Vector3.UP)
	var wall_up = wall_normal.cross(wall_sideways)
	
	#current_speed = 5
	movement_direction = Vector3.ZERO
	movement_direction -= wall_up * Input.get_axis("Backward", "Forward")
	movement_direction += wall_sideways * Input.get_axis("Right", "Left")
	movement_direction += wall_distance
	
	look_at(global_position + wall_normal)
	
	velocity = movement_direction * 5

func check_for_jump(delta : float) -> void:
	if Input.is_action_just_pressed("Jump"):
		state_chart.send_event("Jump")
		jump_reset_timer.stop()

func check_for_floor(delta : float) -> void:
	if is_on_floor():
		state_chart.send_event("Landed")

func initial_jump_processing():
	if current_jump >= constants.jump_strength.size():
		current_jump == 0
	
	velocity.y = constants.jump_strength[current_jump]
	match current_jump:
		3:
			movement_direction = movement_direction.normalized() * constants.max_horizontal_velocity
			velocity = Vector3(movement_direction.x, constants.jump_strength[current_jump], movement_direction.z)
			look_forward(0.0166)
		6:
			movement_direction = movement_direction.normalized() * constants._side_jump_velocity
			velocity = Vector3(movement_direction.x, constants.jump_strength[current_jump], movement_direction.z)
			look_forward(0.0166)
		7:
			movement_direction = movement_direction.normalized() * constants.max_horizontal_velocity
			velocity = Vector3(movement_direction.x, constants.jump_strength[current_jump], movement_direction.z)
			look_forward(0.0166)

func wall_slide_processing(delta : float) -> void:
	delta_v.y = constants.wall_slide_gravity * delta

func normal_jump_processing(delta : float):
	delta_v = movement_direction
	delta_v *= constants.air_acceleration
	if velocity.y > 0:
		delta_v.y = constants.jump_gravity[current_jump]
	else:
		delta_v.y = constants.fall_gravity[current_jump]
	
	if Input.is_action_just_pressed("DiveButton"):
		state_chart.send_event("Dive")
	
	if velocity.y <= 0 and not is_on_floor():
		state_chart.send_event("Fall")

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

func reset_pivot_buffer() -> void:
	joystick_input_buffer.clear()
	joystick_input_buffer.resize(20)

func reset_velocity() -> void:
	velocity = Vector3.ZERO
	delta_v = Vector3.ZERO

func apply_friction(delta : float) -> void:
	var forward_velocity = movement_direction
	forward_velocity *= movement_direction.dot(velocity)
	var lateral_velocity = velocity - forward_velocity
	
	lateral_velocity = lerp(lateral_velocity, Vector3.ZERO, sideways_friction * delta) 
	
	if forward_velocity.length() > constants.max_horizontal_velocity * delta or forward_velocity.dot(movement_direction) < 0:
		forward_velocity = lerp(forward_velocity, Vector3.ZERO, forwards_friction * delta)
	velocity = forward_velocity + lateral_velocity

func apply_slide_friction(delta : float) -> void:
	velocity = lerp(velocity, Vector3.ZERO, (constants.slide_friction * delta))

func start_skidding() -> void:
	pivot = true

func stop_skidding() -> void:
	pivot = false

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

func disable_wall_jump(delta) -> void:
	wall_jump_raycasts.disable()

func check_for_pivots(delta) -> void:
	joystick_input_buffer.push_front(Input.get_vector("Left", "Right", "Backward", "Forward"))
	joystick_input_buffer.pop_back()
	if joystick_input_buffer[0].length() < 0.8:
		return
	for checked_position in joystick_input_buffer:
		for positions in joystick_input_buffer:
			if abs(checked_position.angle_to(positions)) < PI/2.0 and abs(checked_position.angle_to(positions)) > PI/4.0:
				if positions.length() > .8:
					return
			else:
				if checked_position.dot(positions) < -.9:
					state_chart.send_event("Pivot")
