extends AerialMovement


#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "LedgeGrab"
var snapped_to_ledge = false


var height_of_platform := 0
#onready variables

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	
	# Handle state logic
	if _player.is_on_floor():
		_state.update_state("Running")
		return
	if _state.attempting_jump:
		_state._jump_state = _state.jump
		_state.anim_tree["parameters/conditions/ledge hang"] = false
		_state.update_state("Jump")
		return
	# Handle animation tree
	
	# Process movements
	var input = Vector3(_state.camera_relative_movement.x, 0, _state.camera_relative_movement.z)
	var direction = input.signed_angle_to(_state.snap_vector, Vector3.UP)
	
	
	
	# Update relevant counters
	var left_or_right = 0
	var current_fall_gravity = 0
	_state.current_speed = 2
	if not snapped_to_ledge:
		if _state._raycast_left.is_colliding():
			
			while _state._raycast_left.is_colliding():
				_player.global_position.y += .1
				_state._raycast_left.force_raycast_update()
			_player.global_position.y -= .125
			_state.velocity = Vector3.ZERO
			_state._player.velocity = Vector3.ZERO
			_state.move_direction = Vector3.ZERO
			snapped_to_ledge = true
		else:
			current_fall_gravity = constants._fall_gravity
	else:
		var dot = _state.camera_relative_movement.dot(_state.snap_vector)
		_state.move_direction = Vector3.ZERO
		if dot > .9:
			_state.move_direction = _state.snap_vector
			_state.current_speed = 10
			_state._jump_state = _state.jump
			_state.anim_tree["parameters/conditions/ledge hang"] = false
			_state.update_state("Jump")
			return
		elif dot < -.9:
			_state._jump_state = _state.jump
			_state.anim_tree["parameters/conditions/ledge hang"] = false
			_state.update_state("Falling")
			return
		else:
			var continue_sliding = true
			var wall_vector = _state.snap_vector.cross(Vector3.UP)
			var desired_movement = _state.camera_relative_movement.project(wall_vector)
			if desired_movement.dot(wall_vector) > 0:
				left_or_right = 1
				if _state._raycast_right.is_colliding():
					_state._raycast_right.position.y += .2
					_state._raycast_right.force_raycast_update()
					if _state._raycast_right.is_colliding():
						continue_sliding = false
					_state._raycast_right.position.y -= .2
			else:
				left_or_right = -1
				if _state._raycast_left.is_colliding():
					_state._raycast_left.position.y += .2
					_state._raycast_left.force_raycast_update()
					if _state._raycast_left.is_colliding():
						continue_sliding = false
					_state._raycast_left.position.y -= .2
			if continue_sliding:
				_state.move_direction = desired_movement
				_state.current_speed = 2 * _state._controller.input_strength
	_state.anim_tree["parameters/ledge hang/blend_position"] = _state.current_speed * left_or_right
	# Process Physics
	_state.velocity = _state.calculate_velocity(current_fall_gravity, delta)
	
	pass

func reset():
	snapped_to_ledge = false
	_state._reset_animation_parameters()
	_state.anim_tree["parameters/conditions/ledge hang"] = true
	_state.velocity = Vector3(0, _state.velocity.y, 0)
	_state.move_direction = Vector3.ZERO
	_state.current_speed = 0
	_state.snap_vector = -_state._raycast_middle.get_collision_normal()
	var distance = abs((_state._raycast_middle.get_collision_point() - _state._raycast_middle.global_position) *  .577)
	print(_state.snap_vector * distance)
	_player.global_position += _state.snap_vector * distance
	_state.snap_vector.y = 0
	if _state.snap_vector == Vector3.ZERO:
		_state.update_state("Falling")
		return
	_player.transform = _player.transform.looking_at(_player.global_transform.origin + _state.snap_vector, Vector3.UP)
	pass