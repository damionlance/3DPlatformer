extends AerialMovement


#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var state_name = "WallClimb"
var snapped_to_ledge = false

var height_of_platform := 0
#onready variables
var wall_vector = Vector3.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	pass # Replace with function body.

func update(delta):
	wall_vector = Vector3.ZERO
	var lean_vector = Vector3.ZERO
	var distance_to_wall = Vector3.ZERO
	if state._raycast_middle.get_collision_normal() != Vector3.UP:
		wall_vector = state._raycast_middle.get_collision_normal()
		distance_to_wall = state._raycast_middle.get_collision_point() - state._raycast_middle.global_position
		lean_vector += wall_vector
	if state._raycast_right.get_collision_normal() != Vector3.UP:
		if wall_vector == Vector3.ZERO and controller.movement_direction.y > 0:
			wall_vector = state._raycast_right.get_collision_normal()
			distance_to_wall = state._raycast_right.get_collision_point() - state._raycast_right.global_position
		lean_vector += wall_vector
	if state._raycast_left.get_collision_normal() != Vector3.UP:
		if wall_vector == Vector3.ZERO and controller.movement_direction.y > 0:
			wall_vector = state._raycast_left.get_collision_normal()
			distance_to_wall = state._raycast_left.get_collision_point() - state._raycast_left.global_position
		lean_vector += wall_vector
	if wall_vector == Vector3.ZERO:
		return
	
	# Handle state logic
	if player.is_on_floor():
		state.anim_tree["parameters/conditions/wall climb"] = false
		state.update_state("Running")
		return
	if state.attempting_jump:
		state.anim_tree["parameters/conditions/wall climb"] = false
		state.jump_state = state.jump
		directional_input_handling()
		state.current_speed = 10
		player.global_position += wall_vector*.5
		state.update_state("Jump")
		return
	var right_collide = state._raycast_right.is_colliding()
	var left_collide = state._raycast_left.is_colliding()
	var right_collider = state._raycast_right.get_collider()
	var left_collider = state._raycast_left.get_collider()
	if right_collider is StaticBody3D:
		right_collider = right_collider.get_parent().is_in_group("climbable zone")
	if left_collider is StaticBody3D:
		left_collider = left_collider.get_parent().is_in_group("climbable zone")
	if not right_collide and not left_collide:
		if state._raycast_middle.is_colliding():
			state.update_state("LedgeGrab")
			return
		state.jump_state = state.jump
		state.update_state("Falling")
		return
	elif right_collider != null and left_collider != null:
		if (right_collide and not right_collider
			or left_collide and not left_collider):
			if state._raycast_middle.is_colliding():
				state.update_state("LedgeGrab")
				return
			state.jump_state = state.jump
			state.update_state("Falling")
	# Handle animation tree
	# Process movements
	var input = Vector3(state.camera_relative_movement.x, 0, state.camera_relative_movement.z)
	
	var direction = input.signed_angle_to(state.snap_vector, Vector3.UP)
	
	
	
	lean_vector = lean_vector.normalized()
	
	var wall_sideways = wall_vector.cross(Vector3.UP)
	var wall_up = wall_vector.cross(wall_sideways)
	
	lean_into_walls(wall_vector)
	
	# Update relevant counters
	var dot = state.camera_relative_movement.dot(state.snap_vector)
	state.current_speed = 0
	state.move_direction = Vector3.ZERO
	
	#Handle Up and Down Movement
	state.current_speed = 5
	state.move_direction -= wall_up * state.controller.movement_direction.y
	state.move_direction += wall_sideways * state.controller.movement_direction.x
	state.move_direction += distance_to_wall
	var aligned_direction = state.move_direction
	
	state.anim_tree["parameters/wall climb/blend_position"] = Vector2(abs(Vector2(aligned_direction.x, aligned_direction.z).length()),abs(aligned_direction.y))
	
	# Process Physics
	state.velocity = state.calculate_velocity(0, delta)
	
	pass

func directional_input_handling():
	var dir = state.camera_relative_movement.normalized()
	if state.controller.input_strength == 0:
		state.move_direction = wall_vector
	#elif dir.dot(wall_vector) < 0:
	#	state.move_direction = dir.bounce(wall_vector)
	else:
		state.move_direction = dir

func reset():
	state._reset_animation_parameters()
	state.anim_tree["parameters/conditions/wall climb"] = true
	snapped_to_ledge = false
	state.velocity = Vector3(0, state.velocity.y, 0)
	state.move_direction = Vector3.ZERO
	state.current_speed = 0
	state.snap_vector = Vector3.ZERO
	
	for i in 5:
		if state._raycast_right.get_collision_normal() != Vector3.UP or state._raycast_right.get_collision_normal() != Vector3.ZERO:
			state.snap_vector = -state._raycast_middle.get_collision_normal()
		if state._raycast_left.get_collision_normal() != Vector3.UP or state._raycast_left.get_collision_normal() != Vector3.ZERO:
			state.snap_vector = -state._raycast_middle.get_collision_normal()
		state.snap_vector.y = 0
		if state.snap_vector != Vector3.ZERO:
			break
		state._raycast_right.force_raycast_update()
		state._raycast_left.force_raycast_update()
	
	if state.snap_vector == Vector3.ZERO:
		state.update_state("Falling")
		return
	
	var temp = player.transform.looking_at(player.global_transform.origin + state.snap_vector, Vector3.UP)
	if temp != Transform3D():
		player.transform = temp
	pass
