class_name Player extends CharacterBody3D

@export var constants : PlayerPhysicsConstants

var movement_direction := Vector3.ZERO
var speed := 0.0
var speed_coefficient := 1.0
var facing_direction := Vector3.ZERO

var sideways_friction := 7
var forwards_friction := 3

var current_jump := -1
var jump_reset_timer := Timer.new()

# Flags
var pivot:= false
var was_on_floor := false
var delta_v := Vector3.ZERO
var root_velocity := Vector3.ZERO

var character_paused := false

var joystick_input_buffer : Array[Vector2] = []

@onready var state_chart := $%StateChart
@onready var camera := $CameraPivot
@onready var animation_tree := $AnimationTree
@onready var animation_player := $"model/AnimationPlayer"
@onready var coin_sounds = $"Sounds/Coin Collected"
@onready var player_model = $"%model"

#Raycasts
@onready var floor_alignment_raycast := $"%Floor Alignment Raycast"
@onready var wall_jump_raycasts := $"%Wall Jump Raycasts"
@onready var ledge_hang_raycasts := $"%Ledge Hang Raycasts"
@onready var ledge_climb_raycast := $"%Ledge Climb Raycast"

func _ready():
	constants._ready()
	jump_reset_timer.connect("timeout", reset_jumps)
	add_child(jump_reset_timer)
	
	joystick_input_buffer.resize(5)
	
	state_chart.set_expression_property("locked_in_dialogue", false)
	state_chart.set_expression_property("in_interactable", false)

func _physics_process(delta):
	velocity +=  + (delta_v * delta)
	speed = Vector3(velocity.x, 0, velocity.z).length()
	
	move_and_slide()
	
	if not character_paused: input_polling()
	state_chart_expression_update()
	delta_v = Vector3.ZERO

func state_chart_expression_update():
	state_chart.set_expression_property("speed", speed)
	state_chart.set_expression_property("vertical_speed", velocity.y)
	state_chart.set_expression_property("movement_direction", movement_direction)
	state_chart.set_expression_property("current_jump", current_jump)
	state_chart.set_expression_property("is_on_floor", is_on_floor())

func input_polling():
	
	if Input.is_action_just_pressed("Pause"):
		open_pause_menu()
	
	var movement_input = Input.get_vector("Left", "Right", "Backward", "Forward")
	var forwards = camera.get_camera_basis().z
	forwards.y = 0
	forwards = forwards.normalized()
	forwards *= movement_input.y
	var right = camera.get_camera_basis().x * movement_input.x
	movement_direction = -forwards + right

func grounded_movement_processing(delta):
	if Input.is_action_just_pressed("Jump"):
		return
	delta_v = movement_direction
	delta_v *= constants.running_acceleration
	delta_v.y = -1
	
	if not is_on_floor():
		state_chart.send_event("Fall")

func start_ground_pound() -> void:
	if state_chart.get_expression_property("groundpound") == true:
		velocity.y = -constants.terminal_velocity

func stop_ground_pound() -> void:
	state_chart.set_expression_property("groundpound", false)

func wall_climb_processing(_delta) -> void:
	if not wall_jump_raycasts.check_wall_group():
		state_chart.send_event("Fall")
	var wall_normal = wall_jump_raycasts.get_average_wall_normal()
	var wall_distance = wall_jump_raycasts.get_average_wall_distance()
	
	var wall_sideways = wall_normal.cross(Vector3.UP)
	var wall_up = wall_normal.cross(wall_sideways)
	
	
	#current_speed = 5
	var input_direction := Vector3.ZERO
	input_direction -= wall_up * Input.get_axis("Backward", "Forward")
	input_direction += wall_sideways * Input.get_axis("Right", "Left")
	input_direction += wall_distance
	
	look_at(global_position + wall_normal)
	
	velocity = input_direction * 5

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
			var new_movement_direction = movement_direction.normalized() * constants._side_jump_velocity
			velocity = Vector3(new_movement_direction.x, constants.jump_strength[current_jump], new_movement_direction.z)
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
	delta_v.y = -constants.wall_slide_gravity

func normal_jump_processing(delta : float):
	delta_v = movement_direction
	delta_v *= constants.air_acceleration
	if velocity.y > 0:
		delta_v.y = constants.jump_gravity[current_jump]
	else:
		delta_v.y = constants.fall_gravity[current_jump]
	
	if velocity.y < 0 and not is_on_floor():
		state_chart.send_event("Fall")

func set_jump(jump_index : int) -> void:
	current_jump = jump_index

func check_for_dive(_delta : float) -> void:
	if Input.is_action_just_pressed("DiveButton"):
		if not is_on_floor() and movement_direction.length() < 0.15:
			state_chart.send_event("groundpound")
			state_chart.set_expression_property("groundpound", true)
		else:
			state_chart.send_event("Dive")
	elif not Input.is_action_pressed("DiveButton"):
		state_chart.send_event("stop_crouch")
	

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
	
	if forward_velocity.length() > constants.max_horizontal_velocity * speed_coefficient or forward_velocity.dot(movement_direction) < 0:
		
		forward_velocity = lerp(forward_velocity, Vector3.ZERO, forwards_friction/speed_coefficient * delta)
	var temp = velocity.y
	velocity = forward_velocity + lateral_velocity
	velocity.y = temp
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
	
	if forward_velocity.length() > constants.max_horizontal_velocity or forward_velocity.dot(movement_direction) < 0:
		forward_velocity = lerp(forward_velocity, Vector3.ZERO, forwards_friction * delta)
	velocity = forward_velocity + lateral_velocity + vertical_velocity
	if velocity.length() < 1 and Input.get_vector("Left", "Right", "Backward", "Forward") == Vector2.ZERO:
		velocity = Vector3(0, vertical_velocity.y, 0)

func start_skidding() -> void:
	pivot = true
	state_chart.set_expression_property("pivot", true)

func stop_skidding() -> void:
	state_chart.set_expression_property("pivot", false)

func start_crouching() -> void:
	state_chart.set_expression_property("crouching", true)
	speed_coefficient *= 0.25

func stop_crouching() -> void:
	state_chart.set_expression_property("crouching", false)
	speed_coefficient /= 0.25

func align_to_floor(_delta) -> void:
	var floor_normal = floor_alignment_raycast.get_collision_normal()
	if floor_normal == Vector3.ZERO:
		return
	var xform = global_transform
	var new_y = floor_normal
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	if player_model != null:
		player_model.global_transform = player_model.global_transform.interpolate_with(xform, 0.1)

func reset_alignment() -> void:
	rotation = Vector3(0, rotation.y, 0)

func look_forward(_delta) -> void:
	if movement_direction == Vector3.ZERO:
		return
	var normalized_direction = movement_direction.normalized()
	var lookdir = atan2(normalized_direction.x, normalized_direction.z)
	rotation.y = lookdir
	if movement_direction != Vector3.ZERO:
		facing_direction = movement_direction.normalized()
	wall_jump_raycasts.force_update()
	ledge_hang_raycasts.force_update()

func look_backward(_delta : float) -> void:
	var normalized_direction = movement_direction.normalized()
	var lookdir = atan2(normalized_direction.x, normalized_direction.z)
	rotation.y = -lookdir
	if movement_direction != Vector3.ZERO:
		facing_direction = -movement_direction.normalized()
	wall_jump_raycasts.force_update()
	ledge_hang_raycasts.force_update()


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
		if "launch_direction" in hazard.get_parent() and hazard.get_parent().launch_direction != Vector3.ZERO:
			velocity = hazard.get_parent().launch_direction * constants._damage_launch_velocity
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

func open_pause_menu():
	camera.halt_input = true
	$"../".add_child(load("res://scenes/ui/pause screen.tscn").instantiate())
	$"%HUD/MarginContainer".pause_enter()
	get_tree().paused = true

func add_coin(coin_name):
	if not coin_name.contains("LEVELCOIN"):
		Global.UPDATE_COLLECTIBLES("COIN", Global.WORLD_COLLECTIBLES["COIN"] + 1)
	else:
		Global.UPDATE_COLLECTIBLES("LEVEL COIN", Global.WORLD_COLLECTIBLES["LEVEL COIN"] + 1)
	get_node("CanvasLayer/HUD/MarginContainer/counters/" + coin_name.to_lower())._increase_coins()
	coin_sounds.pitch_scale = randf() + .7
	coin_sounds.play()
	return true

func start_ledge_hang() -> void:
	delta_v = Vector3.ZERO
	var raycast_collision_points : Vector3 = ledge_hang_raycasts.downward_raycasts[0].get_collision_point()
	raycast_collision_points -= ledge_hang_raycasts.downward_raycasts[1].get_collision_point()
	raycast_collision_points *= 0.25
	var height_difference : float = raycast_collision_points.y
	
	global_position.y += height_difference
	movement_direction = -wall_jump_raycasts.get_average_wall_normal()
	look_forward(0.0166)

func ledge_hang_processing(_delta : float) -> void:
	velocity = Vector3.ZERO
	movement_direction = wall_jump_raycasts.get_average_wall_normal()
	ledge_hang_raycasts.downward_raycasts[0].force_raycast_update()
	ledge_hang_raycasts.downward_raycasts[1].force_raycast_update()
	
	var horizontal_movement = -Input.get_axis("Left", "Right")
	var vertical_movement = Input.get_axis("Backward", "Forward")
	
	if vertical_movement == 1:
		start_ledge_climb()
		return
	if vertical_movement == -1:
		state_chart.send_event("Fall")
	
	if horizontal_movement > 0:
		if not ledge_hang_raycasts.downward_raycasts[0].is_colliding() or ledge_hang_raycasts.forward_raycasts[0].is_colliding():
			horizontal_movement = 0
	elif horizontal_movement < 0:
		if not ledge_hang_raycasts.downward_raycasts[1].is_colliding() or ledge_hang_raycasts.forward_raycasts[1].is_colliding():
			horizontal_movement = 0
	else:
		return
	
	
	velocity = wall_jump_raycasts.get_average_wall_normal().cross(Vector3.UP)
	velocity *= horizontal_movement * constants.ledge_hang_speed

func bounce(area: Area3D) -> void:
	state_chart.send_event("bounce")

func pause_character(pause : bool) -> void:
	character_paused = pause

var previous_root_motion_position := Vector3.ZERO
var starting_position := Vector3.ZERO
func start_ledge_climb() -> void:
	state_chart.set_expression_property("ledge_climb", true)
	starting_position = global_position
	previous_root_motion_position = Vector3.ZERO

func set_ledge_climb_position(_delta : float) -> void:
	var current_root_motion_position = animation_tree.get_root_motion_position_accumulator()
	var difference : Vector3 = current_root_motion_position - previous_root_motion_position
	previous_root_motion_position = current_root_motion_position
	difference = difference.rotated(Vector3.UP, rotation.y)
	global_position += difference

func stop_ledge_climb() -> void:
	state_chart.set_expression_property("ledge_climb", false)

func get_root_motion() -> Vector3:
	var current_root_motion_position = animation_tree.get_root_motion_position()
	return current_root_motion_position

func reset_root_motion_variables() -> void:
	previous_root_motion_position = Vector3.ZERO
