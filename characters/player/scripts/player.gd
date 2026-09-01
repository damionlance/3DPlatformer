class_name Player extends CharacterBody3D

@export var state_chart : StateChart
@export var physics_constants : PlayerPhysicsConstants
@export var pcam : PhantomCamera3D
@export var anim_tree : AnimationTree
@export var jump_timer : Timer
@export var stair_ahead_ray : RayCast3D
@export var stair_below_ray : RayCast3D

var stage_manager : StageManager

var input_direction : Vector2 = Vector2.ZERO
var move_direction : Vector3 = Vector3.ZERO
var facing_direction : Vector3 = Vector3.ZERO

var current_jump : int = 0
var can_increment_jump : bool = false

var MAX_STEP_HEIGHT := 0.6
var _snapped_to_stairs_last_frame := false
var _last_frame_was_on_floor = -INF

var speed_coefficient : float = 1.0

var sliding : bool = false

func _ready() -> void:
	physics_constants.update_constants()

func _physics_process(delta: float) -> void:
	if is_on_floor(): _last_frame_was_on_floor = Engine.get_physics_frames()
	
	input_handling()
	
	if not _snap_up_stairs_check(delta):
		move_and_slide()
		_snap_down_to_stairs_check()
	
	state_chart.set_expression_property("velocity", velocity)
	state_chart.set_expression_property("is_on_floor", is_on_floor() or _snapped_to_stairs_last_frame)

func reset_special_states() -> void:
	sliding = false

func Idle(delta : float) -> void:
	velocity.y = -1
	apply_grounded_friction(delta)

func default_movement_processing(delta : float) -> void:
	velocity += move_direction * physics_constants.running_acceleration * delta
	velocity.y = -1
	apply_grounded_friction(delta)

func default_jump_processing(delta : float):
	var delta_v = move_direction
	delta_v *= physics_constants.air_acceleration
	if velocity.y > 0:
		delta_v.y = physics_constants.all_jump_gravity[current_jump]
	else:
		delta_v.y = physics_constants.all_fall_gravity[current_jump]
	velocity += delta_v * delta

func restricted_jump_processing(delta : float):
	var delta_v : Vector3 = Vector3.ZERO
	if velocity.y > 0:
		delta_v.y = physics_constants.all_jump_gravity[current_jump]
	else:
		delta_v.y = physics_constants.all_fall_gravity[current_jump]
	velocity += delta_v * delta

func apply_grounded_friction(delta : float) -> void:
	var forward_velocity = move_direction
	forward_velocity *= move_direction.dot(velocity)
	var lateral_velocity = velocity - forward_velocity
	
	lateral_velocity = lerp(lateral_velocity, Vector3.ZERO, physics_constants.sideways_friction * delta)
	
	if forward_velocity.length() > physics_constants.max_horizontal_velocity * speed_coefficient or forward_velocity.dot(move_direction) < 0:
		var max_velocity : Vector3 = move_direction * physics_constants.max_horizontal_velocity
		forward_velocity = lerp(forward_velocity, Vector3.ZERO if move_direction == Vector3.ZERO else max_velocity, physics_constants.forwards_friction/speed_coefficient * delta)
	
	var temp = velocity.y
	velocity = forward_velocity + lateral_velocity
	velocity.y = temp
	if velocity.length() < 1 and Input.get_vector("move_left", "move_right", "move_up", "move_down") == Vector2.ZERO:
		velocity = Vector3(0, velocity.y, 0)

func apply_belly_slide_friction(delta : float) -> void:
	var forward_velocity = move_direction
	forward_velocity *= move_direction.dot(velocity)
	var lateral_velocity = velocity - forward_velocity
	
	lateral_velocity = lerp(lateral_velocity, Vector3.ZERO, physics_constants.sideways_friction * delta)
	
	if forward_velocity.length() > physics_constants.max_horizontal_velocity * speed_coefficient or forward_velocity.dot(move_direction) < 0:
		var max_velocity : Vector3 = move_direction * physics_constants.max_horizontal_velocity
		forward_velocity = lerp(forward_velocity, Vector3.ZERO if move_direction == Vector3.ZERO else max_velocity, physics_constants.forwards_friction/speed_coefficient * delta)
	
	var temp = velocity.y
	velocity = forward_velocity + lateral_velocity
	velocity.y = temp
	if velocity.length() < 1 and Input.get_vector("move_left", "move_right", "move_up", "move_down") == Vector2.ZERO:
		velocity = Vector3(0, velocity.y, 0)

func input_handling() -> void:
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_direction.length() > 1.0:
		input_direction = input_direction.normalized()
	
	state_chart.set_expression_property("input_direction", input_direction)
	
	move_direction = Vector3(input_direction.x, 0, input_direction.y).rotated(Vector3.UP, pcam.rotation.y)
	if Input.is_action_just_pressed("Jump"):
		state_chart.send_event("Jump")
	if Input.is_action_just_pressed("Dive"):
		state_chart.send_event("Dive")

func look_forward(_delta) -> void:
	if move_direction == Vector3.ZERO:
		return
	var normalized_direction = move_direction.normalized()
	var lookdir = atan2(normalized_direction.x, normalized_direction.z)
	rotation.y = lookdir
	if move_direction != Vector3.ZERO:
		facing_direction = move_direction.normalized()

func fall(delta : float) -> void:
	velocity.y += physics_constants.all_fall_gravity[current_jump] * delta

func increment_jump() -> void:
	current_jump += 1
	if current_jump >= 3:
		current_jump = 0

func reset_jumps() -> void:
	current_jump = 0
	can_increment_jump = false

func start_jump(force_jump : int = -1) -> void:
	if force_jump != -1: current_jump == force_jump
	if can_increment_jump:
		increment_jump()
	velocity.y = physics_constants.all_jump_strengths[current_jump]
	jump_timer.stop()

func dive() -> void:
	current_jump = 3
	velocity = Vector3(move_direction.x, 0, move_direction.z) * physics_constants.dive_speed
	velocity.y = physics_constants.all_jump_strengths[current_jump]
	sliding = true

func rollout() -> void:
	current_jump = 4
	velocity.y = physics_constants.all_jump_strengths[current_jump]

func land_on_ground(_delta : float) -> void:
	if not is_on_floor():return
	
	jump_timer.start(7 * 0.0166)
	can_increment_jump = true
	state_chart.send_event("Landed")

func is_surface_too_steep(normal : Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > physics_constants.max_floor_angle

func _run_body_test_motion(from : Transform3D, motion : Vector3, result = null) -> bool:
	if not result: result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)

func _snap_down_to_stairs_check() -> void:
	var did_snap := false
	var floor_below : bool = stair_below_ray.is_colliding() and not is_surface_too_steep(stair_below_ray.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() - _last_frame_was_on_floor == 1
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if _run_body_test_motion(self.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), body_test_result):
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap

func _snap_up_stairs_check(delta : float) -> bool:
	if not is_on_floor() and not _snapped_to_stairs_last_frame: return false
	
	if velocity.y > 0 or (velocity * Vector3(1,0,1)).length() == 0: return false
	
	var expected_move_motion = self.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	
	
	var down_check_result = PhysicsTestMotionResult3D.new()
	if(_run_body_test_motion(step_pos_with_clearance, Vector3(0, -MAX_STEP_HEIGHT*2, 0), down_check_result)):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - global_position).y
		
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_collision_point() - global_position).y > MAX_STEP_HEIGHT: return false
		
		stair_ahead_ray.global_position = down_check_result.get_collision_point() + Vector3(0,MAX_STEP_HEIGHT * .5,0) + expected_move_motion.normalized() * .1
		
		stair_ahead_ray.force_raycast_update()
		if stair_ahead_ray.is_colliding() and not is_surface_too_steep(stair_ahead_ray.get_collision_normal()):
			self.global_position = (step_pos_with_clearance.origin+down_check_result.get_travel())
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false

func enter_movement_constraint(type : String):
	velocity = Vector3.ZERO
	state_chart.send_event("constrained movement")
	anim_tree.set("parameters/conditions/constrained_movement", true)
	anim_tree.set("parameters/ConstrainedMovements/conditions/" + type, true)
