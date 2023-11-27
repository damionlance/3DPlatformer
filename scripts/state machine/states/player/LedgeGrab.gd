extends AerialMovement


#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var state_name = "LedgeGrab"
var snapped_to_ledge = false
var ready_to_move = false

var height_of_platform := 0
#onready variables

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	pass # Replace with function body.

func update(delta):
	
	# Handle state logic
	if player.is_on_floor():
		state.update_state("Running")
		return
	if state.attempting_jump:
		state.jumpstate = state.jump
		state.anim_tree["parameters/conditions/ledge hang"] = false
		state.update_state("Jump")
		return
	# Handle animation tree
	
	# Process movements
	var input = Vector3(state.camera_relative_movement.x, 0, state.camera_relative_movement.z)
	var direction = input.signed_angle_to(state.snap_vector, Vector3.UP)
	
	if not ready_to_move and input == Vector3.ZERO:
		ready_to_move = true
	
	# Update relevant counters
	var left_or_right = 0
	var current_fall_gravity = 0
	state.current_speed = 2
	if not snapped_to_ledge:
		if state._raycast_left.is_colliding() or state._raycast_right.is_colliding():
			if state._raycast_left.is_colliding() != state._raycast_right.is_colliding():
				state.jumpstate = state.jump
				state.update_state("Falling")
				return
			var increments := 0
			while state._raycast_left.is_colliding() or state._raycast_right.is_colliding():
				increments += 1
				player.global_position.y += .1
				state._raycast_left.force_raycast_update()
				state._raycast_right.force_raycast_update()
				if state._raycast_left.is_colliding() != state._raycast_right.is_colliding() or increments == 10:
					state.jumpstate = state.jump
					state.update_state("Falling")
					return
			player.global_position.y -= .125
			state.velocity = Vector3.ZERO
			state.player.velocity = Vector3.ZERO
			state.move_direction = Vector3.ZERO
			state.current_speed = 0
			var temp = player.transform.looking_at(player.global_transform.origin + state.snap_vector, Vector3.UP)
			if temp != Transform3D():
				player.transform = temp
			state.anim_tree["parameters/conditions/ledge hang"] = true
			snapped_to_ledge = true
		else:
			current_fall_gravity = constants._fall_gravity
	else:
		var dot = state.camera_relative_movement.dot(state.snap_vector)
		state.move_direction = Vector3.ZERO
		if not ready_to_move:
			return
		if dot > .9:
			state.move_direction = state.snap_vector
			state.current_speed = 10
			state.jumpstate = state.jump
			state.anim_tree["parameters/conditions/ledge hang"] = false
			state.update_state("Jump")
			return
		elif dot < -.9:
			state.jumpstate = state.jump
			state.anim_tree["parameters/conditions/ledge hang"] = false
			state.update_state("Falling")
			return
		else:
			var continue_sliding = true
			var wall_vector = state.snap_vector.cross(Vector3.UP)
			var desired_movement = state.camera_relative_movement.project(wall_vector)
			if desired_movement.dot(wall_vector) > 0:
				left_or_right = 1
				if state._raycast_right.is_colliding():
					state._raycast_right.position.y += .2
					state._raycast_right.force_raycast_update()
					if state._raycast_right.is_colliding():
						continue_sliding = false
					state._raycast_right.position.y -= .2
					state._raycast_right.force_raycast_update()
				else:
					continue_sliding = false
			else:
				left_or_right = -1
				if state._raycast_left.is_colliding():
					state._raycast_left.position.y += .2
					state._raycast_left.force_raycast_update()
					if state._raycast_left.is_colliding():
						continue_sliding = false
					state._raycast_left.position.y -= .2
				else:
					continue_sliding = false
					state._raycast_left.force_raycast_update()
			if continue_sliding:
				state.move_direction = desired_movement
				state.current_speed = 2 * state.controller.input_strength
	state.anim_tree["parameters/ledge hang/blend_position"] = state.current_speed * left_or_right
	# Process Physics
	state.velocity = state.calculate_velocity(current_fall_gravity, delta)
	
	pass

func reset():
	snapped_to_ledge = false
	ready_to_move = false
	state._reset_animation_parameters()
	var distance = abs((state._raycast_middle.get_collision_point() - state._raycast_middle.global_position) *  .577)
	player.global_position += state.snap_vector * distance
	if state._raycast_middle.is_colliding():
		state.snap_vector = -state._raycast_middle.get_collision_normal()
	else:
		state._raycast_middle.target_position *= -1
		state._raycast_middle.force_raycast_update()
		if state._raycast_middle.is_colliding():
			state.snap_vector = -state._raycast_middle.get_collision_normal()
		state._raycast_middle.target_position *= -1
	if abs(state.snap_vector.y) < 0.00001:
		state.snap_vector.y = 0.0
	state.snap_vector = state.snap_vector.normalized()
	if state.snap_vector == Vector3.ZERO or state.snap_vector.y != 0:
		state.update_state("Falling")
		return
	
	var temp = player.transform.looking_at(player.global_transform.origin + state.snap_vector, Vector3.UP)
	if temp != Transform3D():
		player.transform = temp
	pass
