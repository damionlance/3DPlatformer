extends AerialMovement

class_name SpinFall

#private variables
var _state_name = "SpinFall"


# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	_player.anim_tree.travel("Spin Jump")
	
	spin_jump_drift()
	
	if _player.is_on_floor():
		if _state._controller.movement_direction:
			_state.update_state("Running")
			return
		_state.snap_vector = Vector3.DOWN
		_state.update_state("Idle")
		return
	if _state._controller._jump_state == _state._controller.jump_released:
		_state.velocity.y *= .6
		_state.update_state("Falling")
		return
	
	_state.velocity = _state.calculate_velocity(_spin_fall_gravity, delta)
	pass

func reset():
	_state.snap_vector = Vector3.ZERO
	pass
