extends AerialMovement

class_name ReelIn

#private variables
var _state_name = "ReelIn"

#onready variables
onready var _grapple_raycast = $"../../GrappleRaycast"
onready var _friendo = $"../../FriendoHomingNode/Friendo"

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
	if wall_collision_check() == wall_collision.wallSlide:
		_player.grappling = false
		_state.update_state("WallSlide")
		return
	if wall_collision_check() == wall_collision.ledgeGrab:
		_player.grappling = false
		_state.update_state("LedgeGrab")
		return
	if _state.attempting_jump:
		_player.grappling = false
		_state.update_state("Jump")
		return
	# Handle animation tree
	
	# Process movements
	
	var diff = _friendo.global_transform.origin - _player.global_transform.origin
	if diff.length() < 1:
		_player.transform = _player.transform.looking_at(_player.global_transform.origin + -_state._raycast_middle.get_collision_normal(), Vector3.UP)
	else:
		_player.transform = _player.transform.looking_at(_friendo.global_transform.origin, Vector3.UP)
	# Update all relevant counters
	
	# Process physics
	_state.move_direction = diff.normalized()
	_state.current_speed += 1.5
	_state.velocity = _state.calculate_velocity(0, delta)
	
	pass

func reset():
	shorthop_timer = 0
	_state.snap_vector = Vector3.ZERO
	pass
