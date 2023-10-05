extends AerialMovement


#private variables
var _state_name = "PopperBounce"

#onready variables

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle all state logic
	if _state.attempting_dive:
		_state.update_state("Dive")
		return
	
	match wall_collision_check():
		wall_collision.wallSlide:
			_state.update_state("WallSlide")
			return
		wall_collision.ledgeGrab:
			_state.update_state("LedgeGrab")
			return
	
	if _state.velocity.y < 0:
		_state.update_state("Falling")
		return
	# Handle animation tree
	
	# Process movements
	standard_aerial_drift()
	
	# Update all relevant counters
	
	# Process physics
	_state.velocity = _state.calculate_velocity(constants._side_jump_gravity, delta)
	pass

func reset():
	_state._reset_animation_parameters()
	_state.anim_tree["parameters/conditions/jump"] = true
	
	constants.entering_jump_angle = Vector3(_player.popperAngle.x, 0, _player.popperAngle.z)
	_state.move_direction = Vector3(_player.popperAngle.x, 0, _player.popperAngle.z)
	_state.current_speed = constants.wall_jump_speed * constants.entering_jump_angle.length()
	_state.snap_vector = Vector3.ZERO
	_state.velocity.y = constants._side_jump_strength
	_player.transform = _player.transform.looking_at(_player.global_transform.origin + _state.move_direction, Vector3.UP)
	pass
