extends AerialMovement

class_name Falling

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Falling"

#onready variables

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle animation tree
	_player.anim_tree.travel("Fall")
	
	# Process movements
	standard_aerial_drift()
	
	# Update relevant counters
	
	# Handle state logic
	if _player.is_on_floor():
		if _state.input_direction:
			_state.update_state("Running")
			return
		_state.snap_vector = Vector3.DOWN
		_state.update_state("Idle")
		_state.just_landed = true
		return
	if wall_jump_collision_check() and _state._allow_wall_jump:
		_state.update_state("WallSlide")
		return
	
	var current_fall_gravity
	match current_jump:
		1: current_fall_gravity = _fall_gravity
		2: current_fall_gravity = _fall2_gravity
		_: current_fall_gravity = _fall_gravity
	
	# Process Physics
	_state.velocity = _state.calculate_velocity(current_fall_gravity, delta)
	
	pass

func reset():
	_state.snap_vector = Vector3.ZERO
	pass
