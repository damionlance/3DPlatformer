extends AerialMovement

class_name ReelIn

#private variables
var _state_name = "ReelIn"

#onready variables
onready var _grapple_raycast = $"../../../../GrappleRaycast"
onready var _friendo = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle all state logic
	if _state.attempting_dive:
		_player.grappling = false
		_state.update_state("Dive")
		return
	if wall_jump_collision_check():
		_player.grappling = false
		_state.update_state("WallSlide")
		return
	if _state.attempting_jump:
		_player.grappling = false
		_state.update_state("Jump")
		return
	# Handle animation tree
	
	# Process movements
	standard_aerial_drift()
	
	# Update all relevant counters
		
	# Process physics
	
	_grapple_raycast.cast_to = _grapple_raycast.to_local(_friendo.global_transform.origin)
	_state.velocity = lerp(_state.velocity, $"../../GrappleRaycast".cast_to, .15)
	pass

func reset():
	
	shorthop_timer = 0
	entering_jump_angle = _state._controller.movement_direction
	_state.snap_vector = Vector3.ZERO
	_state.velocity.y += _jump_strength
	_player.transform = _player.transform.looking_at(_player.global_transform.origin + _state.move_direction, Vector3.UP)
	pass
