extends AerialMovement

class_name Jump

#private variables
var _state_name = "Jump"

#onready variables

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle animation tree
	_player.anim_tree.travel("Jump")
	
	# Process movements
	standard_aerial_drift()
	
	# Update all relevant counters
	shorthop_timer += 1
	# Handle all state logic
	if _state.attempting_dive:
		_state.update_state("Dive")
		return
	
	if wall_jump_collision_check():
		_state.update_state("WallSlide")
		return
	
	if _state._controller._jump_state == _state._controller.jump_released and shorthop_timer == shorthop_buffer:
		_state.velocity.y *= .6
		_state.update_state("Falling")
		return
	if _state.velocity.y < 0:
		_state.update_state("Falling")
		return
		
	# Process physics
	var current_jump_gravity
	match current_jump:
		1: current_jump_gravity = _jump_gravity
		2: current_jump_gravity = _jump2_gravity
		_: current_jump_gravity = _jump_gravity
		
	_state.velocity = _state.calculate_velocity(current_jump_gravity, delta)
	pass

func reset():
	if _state.just_landed:
		current_jump += 1
	else:
		current_jump = 1
	
	shorthop_timer = 0
	entering_jump_angle = _state._controller.movement_direction
	_state.snap_vector = Vector3.ZERO
	_state.velocity.y = _jump_strength
	_player.transform = _player.transform.looking_at(_player.global_transform.origin + _state.move_direction, Vector3.UP)
	pass
