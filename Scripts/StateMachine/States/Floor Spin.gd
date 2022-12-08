extends GroundedMovement

class_name FloorSpin

#private variables
var _state_name = "Floor Spin"

var _spinning_timer := 90
var _spinning_buffer := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle All State Logic
	if _state.attempting_jump:
		_state.update_state("SpinJump")
		return
	if _state._controller.spin_entered:
		_spinning_buffer = 0
	_spinning_buffer += 1
	if _spinning_buffer == _spinning_timer:
		_state.update_state("Idle")
	
	# Handle Animation Tree
	_player.anim_tree.travel("Spin Jump")
	
	# Handle movements
	grounded_movement_processing()
	
	# Update relevant timers
	
	
		
	
	#Process Physics
	_state.velocity = _state.calculate_velocity(-1, delta)
	pass

func reset():
	_state.snap_vector = Vector3.DOWN
	_spinning_buffer = 0
	pass