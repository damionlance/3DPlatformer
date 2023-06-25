extends AerialMovement


#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "WallClimb"
var snapped_to_ledge = false

var height_of_platform := 0
#onready variables
var wall_vector = Vector3.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	wall_vector = Vector3.ZERO
	var lean_vector = Vector3.ZERO
	var distance_to_wall = Vector3.ZERO
	if _state._raycast_middle.get_collision_normal() != Vector3.UP:
		wall_vector = _state._raycast_middle.get_collision_normal()
		distance_to_wall = _state._raycast_middle.get_collision_point() - _state._raycast_middle.global_position
		lean_vector += wall_vector
	if _state._raycast_right.get_collision_normal() != Vector3.UP:
		if wall_vector != Vector3.ZERO and _controller.movement_direction.y > 0:
			wall_vector = _state._raycast_right.get_collision_normal()
			distance_to_wall = _state._raycast_right.get_collision_point() - _state._raycast_right.global_position
		lean_vector += wall_vector
	if _state._raycast_left.get_collision_normal() != Vector3.UP:
		if wall_vector != Vector3.ZERO and _controller.movement_direction.y > 0:
			wall_vector = _state._raycast_left.get_collision_normal()
			distance_to_wall = _state._raycast_left.get_collision_point() - _state._raycast_left.global_position
		lean_vector += wall_vector
	if wall_vector == Vector3.ZERO:
		return
	
	# Handle state logic
	if _player.is_on_floor():
		_state.update_state("Running")
		return
	if _state.attempting_jump:
		_state._jump_state = _state.jump
		directional_input_handling()
		_state.current_speed = 10
		_player.global_position += wall_vector*.5
		_state.update_state("Jump")
		return
	var right_collide = _state._raycast_right.is_colliding()
	var left_collide = _state._raycast_left.is_colliding()
	var right_collider = _state._raycast_right.get_collider()
	var left_collider = _state._raycast_left.get_collider()
	if right_collider is StaticBody3D:
		right_collider = right_collider.get_parent().is_in_group("climbable zone")
	if left_collider is StaticBody3D:
		left_collider = left_collider.get_parent().is_in_group("climbable zone")
	if not right_collide and not left_collide:
		_state._jump_state = _state.jump
		_state.update_state("Falling")
	elif right_collider != null and left_collider != null:
		if (right_collide and not right_collider
			or left_collide and not left_collider):
			_state._jump_state = _state.jump
			_state.update_state("Falling")
	# Handle animation tree
	# Process movements
	var input = Vector3(_state.camera_relative_movement.x, 0, _state.camera_relative_movement.z)
	
	var direction = input.signed_angle_to(_state.snap_vector, Vector3.UP)
	
	
	
	lean_vector = lean_vector.normalized()
	
	var wall_sideways = wall_vector.cross(Vector3.UP)
	var wall_up = wall_vector.cross(wall_sideways)
	
	lean_into_walls(wall_vector)
	
	# Update relevant counters
	var dot = _state.camera_relative_movement.dot(_state.snap_vector)
	_state.current_speed = 0
	_state.move_direction = Vector3.ZERO
	
	#Handle Up and Down Movement
	_state.current_speed = 5
	_state.move_direction -= wall_up * _state._controller.movement_direction.y
	_state.move_direction += wall_sideways * _state._controller.movement_direction.x
	_state.move_direction += distance_to_wall
	
	# Process Physics
	_state.velocity = _state.calculate_velocity(0, delta)
	
	pass

func directional_input_handling():
	var dir = _state.camera_relative_movement.normalized()
	if _state._controller.input_strength == 0:
		_state.move_direction = wall_vector
	#elif dir.dot(wall_vector) < 0:
	#	_state.move_direction = dir.bounce(wall_vector)
	else:
		_state.move_direction = dir

func reset():
	snapped_to_ledge = false
	_state.velocity = Vector3(0, _state.velocity.y, 0)
	_state.move_direction = Vector3.ZERO
	_state.current_speed = 0
	if _state._raycast_middle.get_collision_normal() != Vector3.UP or _state._raycast_middle.get_collision_normal() != Vector3.ZERO:
		_state.snap_vector = -_state._raycast_middle.get_collision_normal()
	elif _state._raycast_right.get_collision_normal() != Vector3.UP or _state._raycast_right.get_collision_normal() != Vector3.ZERO:
		_state.snap_vector = -_state._raycast_right.get_collision_normal()
	elif _state._raycast_left.get_collision_normal() != Vector3.UP or _state._raycast_left.get_collision_normal() != Vector3.ZERO:
		_state.snap_vector = -_state._raycast_left.get_collision_normal()
	_state.snap_vector.y = 0
	_player.transform = _player.transform.looking_at(_player.global_transform.origin + _state.snap_vector, Vector3.UP)
	if _player.anim_tree != null:
		_player.anim_tree.travel("Run")
		_player.player_anim_tree["parameters/Run/Blend/blend_amount"] = 0
	pass
