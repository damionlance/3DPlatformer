extends AerialMovement

class_name SideFlip

var _state_name = "SideFlip"

func _ready():
	_state.state_dictionary[_state_name] = self
	_state.update_state(_state_name)

func update(delta):
	_player.anim_tree.travel("Side Flip")
	
	if wall_jump_collision_check():
		_state.update_state("WallSlide")
		return
	if _player.is_on_floor():
		if _state._controller.movement_direction:
			_state.update_state("Running")
			return
		_state.snap_vector = Vector3.DOWN
		_state.update_state("Idle")
		_state.just_landed = true
		return
	
	_state.velocity = _state.calculate_velocity(_side_jump_gravity, delta)
	
	pass

func reset():
	_state.move_direction = -_state.move_direction
	_state.current_speed = 8
	_state.velocity.y = _side_jump_strength
	_state.snap_vector = Vector3.ZERO
	_player.transform = _player.transform.looking_at(_player.global_transform.origin + _state.move_direction, Vector3.UP)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
