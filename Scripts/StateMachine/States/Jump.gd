extends AerialMovement

class_name Jump

#private variables
var _state_name = "Jump"

#onready variables

var entering_angle : Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle animation tree
	_player.anim_tree.travel("Jump" + String(current_jump))
	
	# Process movements
	standard_aerial_drift()
	
	# Update all relevant counters
	shorthop_timer += 1
	
	# Handle all state logic
	if _state._dive_state == _state.dive_pressed:
		_state.update_state("Dive")
		return
	
	if _state.wall_jump_collision_check() and _state._allow_wall_jump:
		_state.update_state("WallSlide")
		return
	
	if not _state.attempting_jump and shorthop_timer == _state._shorthop_buffer:
		_state.velocity.y *= .6
		_state.update_state("Falling")
		return
	if _state.velocity.y < 0:
		_state.update_state("Falling")
		return
		
	# Process physics
	_state.velocity = _state.calculate_velocity(_state._jump_gravity, delta)
	pass

func reset():
	if just_landed:
		current_jump += 1
	else:
		current_jump = 1
	
	shorthop_timer = 0
	_state.entering_jump_angle = _state.input_direction
	_state.snap_vector = Vector3.ZERO
	_state.velocity.y = _state._jump_strength
	_player.transform = _player.transform.looking_at(_player.global_transform.origin + _state.move_direction, Vector3.UP)
	pass
