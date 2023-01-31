extends AerialMovement

class_name LedgeGrab

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "LedgeGrab"
var snapped = false
#onready variables

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	
	# Handle state logic
	if _state.attempting_jump:
		_state.update_state("Jump")
		return
	# Handle animation tree
	
	# Process movements
	var input = Vector3(_state.camera_relative_movement.x, 0, _state.camera_relative_movement.z)
	var direction = input.signed_angle_to(_state.snap_vector, Vector3.UP)
	
	
	
	# Update relevant counters
	
	var current_fall_gravity = 0
	if not snapped:
		if _state._raycast_left.is_colliding():
			_state.velocity = Vector3.ZERO
			_state._player.velocity = Vector3.ZERO
			snapped = true
		else:
			current_fall_gravity = _jump_gravity
	else:
		if _state._controller.movement_direction.y > .5:
			_state.update_state("Jump")
			return
		if _state._controller.movement_direction.y < -.5:
			_state.update_state("Falling")
			return
		_state.move_direction = _state.snap_vector.cross(Vector3.UP) * sign(direction)
		_state.current_speed = 1
	
	# Process Physics
	_state.velocity = _state.calculate_velocity(current_fall_gravity, delta)
	
	pass

func reset():
	snapped = false
	_state.velocity = Vector3(0, _state.velocity.y, 0)
	_state.move_direction = Vector3.ZERO
	_state.current_speed = 0
	_state.snap_vector = -_state._raycast_middle.get_collision_normal()
	_player.transform = _player.transform.looking_at(_player.global_transform.origin + _state.snap_vector, Vector3.UP)
	if _player.anim_tree != null:
		_player.anim_tree.travel("Running")
		_player.player_anim_tree["parameters/Run/Blend/blend_amount"] = 0
	pass
