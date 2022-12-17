extends AerialMovement

var _state_name = "SwingFromFriendo"

var hinge : HingeJoint

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	if _controller._throw_state == 0:
		_state.update_state("Falling")
	if _state.attempting_dive:
		_state.update_state("Dive")
		return
	if _state.attempting_jump:
		_state.update_state("Jump")
		return
	_state.velocity = _state.calculate_velocity(_jump_gravity, delta)
	
	pass

func reset():
	_state.velocity.y = 0
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
