extends GroundedMovement

class_name DiveFloor


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Dive Floor"

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle state changes
	if _state.current_speed <= .5:
		_state.update_state("Running")
		return
	if (_player.is_on_floor()):
		_state.current_speed *= _state.ground_friction
		if _state.attempting_jump:
			_state._jump_state = _state.rollout
			_state.update_state("Jump")
			return
		if _state.current_speed < .01:
			_state.current_speed = 0
	else:
		_state._jump_state = _state.jump
		_state.update_state("Falling")
	
	# Handle animation tree
	
	# Process relevant timers
	
	# Handle inputs
	
	# Process Physics
	_state.velocity = _state.calculate_velocity(-9.8, delta)
	pass

func reset():
	_state.snap_vector = Vector3.DOWN
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
