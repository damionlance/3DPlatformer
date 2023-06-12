extends AerialMovement


#private variables
var _state_name = "ReelIn"

#onready variables
@onready var _grapple_raycast = $"../../../GrappleRaycast"
@onready var _friendo = $"../../../FriendoHomingNode/Friendo"

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

var altered

func update(delta):
	# Handle all state logic
	if _state.attempting_dive:
		_player.grappling = false
		_state._jump_state = _state.dive
		_state.update_state("Jump")
		return
	if _state.attempting_jump:
		_player.grappling = false
		_state._jump_state = _state.jump
		_state.update_state("Jump")
		return
	# Handle animation tree
	
	# Process movements
	var diff = altered - _player.global_transform.origin
	if diff.length() < 1:
		_player.grappling = false
		_state._jump_state = _state.jump
		_state.update_state("Falling")
		return
	else:
		var direction = altered
		direction.y = _player.transform.origin.y
		_player.transform = _player.transform.looking_at(direction, Vector3.UP)
	# Update all relevant counters
	
	# Process physics
	_state.move_direction = diff.normalized()
	_state.current_speed += 1.5 if _state.current_speed < max_reel_in else 0.0
	_state.velocity = _state.calculate_velocity(0, delta)
	
	pass

func reset():
	_player.grappling = false
	altered = _friendo.global_position
	altered.y -= 1.25
	shorthop_timer = 0
	_state.snap_vector = Vector3.ZERO
	pass
