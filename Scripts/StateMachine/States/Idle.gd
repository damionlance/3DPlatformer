extends GroundedMovement

class_name Idle

#private variables
var _state_name = "Idle"
var _keys

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	_state.update_state(_state_name)
	pass # Replace with function body.

func update(delta):
	# Handle animation Tree
	_player.anim_tree.travel("Idle1")
	
	# Process inputs
	_state.current_speed *= floor_fricion
	
	# Handle all relevant timers
	
	# Handle all states
	if not _player.is_on_floor():
		_state.update_state("Falling")
	if _state.input_direction:
		_state.update_state("Running")
		return
	else:
		_state.current_speed = 0
		_state.velocity = Vector3.ZERO
	if  _state._jump_state == _state.jump_pressed:
		_state.update_state("Jump")
		return
	
	# Process physics
	_state.velocity = _state.calculate_velocity(0, delta)
	pass

func reset():
	_state._air_drift_state = _state.not_air_drifting
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
