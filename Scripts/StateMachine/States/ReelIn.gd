extends AerialMovement

class_name ReelIn

#private variables
var _state_name = "ReelIn"

#onready variables
onready var _grapple_raycast = $"../../GrappleRaycast"
onready var _friendo = $"../../FriendoHomingNode/Friendo"

var starting_position

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	print("Hi")
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
	
	# Update all relevant counters
		
	# Process physics
	_player.transform.origin = lerp(_player.transform.origin, _friendo.global_transform.origin, .15)
	
	pass

func reset():
	print("Hi")
	starting_position = _player.global_transform.origin
	_state.velocity = Vector3.ZERO
	_state.move_direction = Vector3.ZERO
	shorthop_timer = 0
	_state.snap_vector = Vector3.ZERO
	_player.transform = _player.transform.looking_at(_friendo.global_transform.origin, Vector3.UP)
	pass
