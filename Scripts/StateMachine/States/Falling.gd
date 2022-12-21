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
	
	# Handle state logic
	if _state.attempting_dive:
		_state.update_state("Dive")
		return
	if _player.is_on_floor():
		_state.snap_vector = Vector3.DOWN
		_state.update_state("Running")
		_state.just_landed = true
		return
	if wall_jump_collision_check():
		_state.update_state("WallSlide")
		return
	if _state.attempting_throw:
		_state._throw()
	
	# Handle animation tree
	
	# Process movements
	standard_aerial_drift()
	
	# Update relevant counters
	
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
	if _player.anim_tree != null:
		_player.anim_tree.travel("Fall")
	pass
