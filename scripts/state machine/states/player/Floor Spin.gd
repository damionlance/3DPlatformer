extends GroundedMovement

#private variables
var _state_name = "Floor Spin"

var _spinning_timer := 90
var _spinning_buffer := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle All State Logic
	if not _player.is_on_floor():
		_state._jump_state = _state.spin_jump
		_state.update_state("Falling")
		return
	if _state.attempting_jump:
		_state._jump_state = _state.spin_jump
		_state.update_state("Jump")
		return
	if _state._controller.spin_entered:
		_spinning_buffer = 0
	_spinning_buffer += 1
	if _spinning_buffer == _spinning_timer:
		_state.anim_tree["parameters/conditions/running"] = true
		_state.anim_tree["parameters/conditions/spinning"] = false
		_state.update_state("Running")
	
	# Handle Animation Tree
	
	# Handle movements
	grounded_movement_processing()
	
	# Update relevant timers
	
	
	#Process Physics
	_state.velocity = _state.calculate_velocity(-1, delta)
	pass

func reset():
	_state._reset_animation_parameters()
	_state.anim_tree["parameters/conditions/spinning"] = true
	_player.rotation.z = 0
	_state.snap_vector = Vector3.DOWN
	_spinning_buffer = 0
	pass
