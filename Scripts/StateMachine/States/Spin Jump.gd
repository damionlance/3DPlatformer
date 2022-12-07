extends AerialMovement

class_name SpinJump

#private variables
var _state_name = "SpinJump"

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle All State Logic
	if _state._controller._jump_state == _state._controller.jump_released:
		_state.velocity.y *= .6
		_state.update_state("Falling")
		return
	if _state.velocity.y < 0:
		_state.update_state("SpinFall")
		return
	
	# Handle Animation Tree
	_player.anim_tree.travel("Spin Jump")
	
	# Handle movements
	spin_jump_drift()
	
	# Update relevant timers
	
	
		
	
	#Process Physics
	_state.velocity = _state.calculate_velocity(_spin_jump_gravity, delta)
	pass

func reset():
	_state.snap_vector = Vector3.ZERO
	_state.velocity.y = _spin_jump_strength
	pass
