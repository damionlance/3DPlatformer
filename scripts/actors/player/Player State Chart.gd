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
var was_on_floor := false
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

func wall_climb_processing(_delta) -> void:
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

func check_for_jump(_delta : float) -> void:
	if Input.is_action_just_pressed("Jump"):
		state_chart.send_event("Jump")
		jump_reset_timer.stop()

func check_for_floor(_delta : float) -> void:
	if is_on_floor():
		state_chart.send_event("Landed")

func initial_jump_processing():
	if current_jump >= constants.jump_strength.size():
		current_jump = 0
	
	velocity.y = constants.jump_strength[current_jump]
	match current_jump:
		3:
			print(velocity)
			var new_movement_direction = movement_direction.normalized() * constants._side_jump_velocity
			velocity = Vector3(new_movement_direction.x, constants.jump_strength[current_jump], new_movement_direction.z)
			print(velocity)
			look_forward(0.0166)
		6:
			var new_movement_direction = movement_direction.normalized() * constants._side_jump_velocity
			velocity = Vector3(new_movement_direction.x, constants.jump_strength[current_jump], new_movement_direction.z)
			look_forward(0.0166)
		7:
			var new_movement_direction = movement_direction.normalized() * constants.max_horizontal_velocity
			velocity = Vector3(new_movement_direction.x, constants.jump_strength[current_jump], new_movement_direction.z)
			look_forward(0.0166)

func wall_slide_processing(delta : float) -> void:
	delta_v.y = constants.wall_slide_gravity * delta

func normal_jump_processing(_delta : float):
	delta_v = movement_direction
	delta_v *= constants.air_acceleration
	if velocity.y > 0:
		delta_v.y = constants.jump_gravity[current_jump]
	else:
		delta_v.y = constants.fall_gravity[current_jump]
	
	if Input.is_action_just_pressed("DiveButton"):
		state_chart.send_event("Dive")
	
	if velocity.y < 0 and not is_on_floor():
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
	jump_reset_timer.stop()

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
	if velocity.length() < 1 and Input.get_vector("Left", "Right", "Backward", "Forward") == Vector2.ZERO:
		velocity = Vector3(0, velocity.y, 0)

func apply_slide_friction(delta : float) -> void:
	velocity = lerp(velocity, Vector3.ZERO, (constants.slide_friction * delta))
	if velocity.length() < 1:
		velocity = Vector3(0, velocity.y, 0)

func apply_air_friction(delta : float) -> void:
	var vertical_velocity = Vector3(0, velocity.y, 0)
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	var forward_velocity = movement_direction
	forward_velocity *= movement_direction.dot(horizontal_velocity)
	var lateral_velocity = horizontal_velocity - forward_velocity
	
	lateral_velocity = lerp(lateral_velocity, Vector3.ZERO, (sideways_friction / 8) * delta) 
	
	if forward_velocity.length() > constants.max_horizontal_velocity * delta or forward_velocity.dot(movement_direction) < 0:
		forward_velocity = lerp(forward_velocity, Vector3.ZERO, forwards_friction * delta)
	velocity = forward_velocity + lateral_velocity + vertical_velocity
	if velocity.length() < 1 and Input.get_vector("Left", "Right", "Backward", "Forward") == Vector2.ZERO:
		velocity = Vector3(0, velocity.y, 0)

func start_skidding() -> void:
	pivot = true

func stop_skidding() -> void:
	pivot = false

func align_to_floor(_delta) -> void:
	var floor_normal = floor_alignment_raycast.get_collision_normal()
	if floor_normal == Vector3.ZERO:
		return
	var xform = global_transform
	var new_y = floor_normal
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	global_transform = global_transform.interpolate_with(xform, 0.1)

func reset_alignment() -> void:
	rotation = Vector3(0, rotation.y, 0)

func look_forward(_delta) -> void:
	var normalized_direction = movement_direction.normalized()
	var lookdir = atan2(normalized_direction.x, normalized_direction.z)
	rotation.y = lookdir
	if movement_direction != Vector3.ZERO:
		facing_direction = movement_direction.normalized()

func look_backward(_delta : float) -> void:
	var normalized_direction = movement_direction.normalized()
	var lookdir = atan2(normalized_direction.x, normalized_direction.z)
	rotation.y = -lookdir
	if movement_direction != Vector3.ZERO:
		facing_direction = -movement_direction.normalized()


func disable_wall_jump(_delta) -> void:
	wall_jump_raycasts.disable()

func check_for_pivots(_delta : float) -> void:
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
	return

func attach_to_object(object_type : String) -> void:
	match object_type:
		"Climbable Rope":
			state_chart.send_event("Rope Climb")

func hazard_reaction(hazard : Node) -> void:
	if hazard.is_in_group("water"):
		$"Respawn Manager".process_respawn()
	if hazard.is_in_group("moving hazard"):
		state_chart.send_event("Take Damage")
		state_chart.send_event("Jump")
		if hazard.get_parent().get_parent().get_parent().launch_direction != Vector3.ZERO:
			velocity = hazard.get_parent().get_parent().get_parent().launch_direction * constants._damage_launch_velocity
		else:
			var launch_direction = global_position - hazard.global_position
			launch_direction.y = 0
			velocity = launch_direction.normalized() * constants._damage_launch_velocity
	return

func intangible(delta : float)->void:
	$"%Blinking Animation Player".play("blinking")

func ensure_player_is_visible() -> void:
	$"%Blinking Animation Player".play("RESET")

func respawn(new_position : Vector3) -> void:
	global_position = new_position
