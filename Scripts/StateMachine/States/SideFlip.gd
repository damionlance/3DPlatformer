extends "aerial_movement.gd"

class_name SideFlip

var _state_name = "SideFlip"

func _ready():
	_state.state_dictionary[_state_name] = self

func update(delta):
	if _state.attempting_dive and not (_state._jump_state == _state.dive or _state._jump_state == _state.rollout):
		_state.update_state("Dive")
		return
	match wall_collision_check():
		wall_collision.wallSlide:
			_state.update_state("WallSlide")
			return
		wall_collision.ledgeGrab:
			_state.update_state("LedgeGrab")
			return
	if _state.velocity.y < 0:
		_state.update_state("Falling")
		return
	if _player.is_on_floor():
		_state.snap_vector = Vector3.DOWN
		_state.update_state("Running")
		_state.just_landed = true
		return
	if _state.attempting_throw:
		_state._throw()
	
	_state.velocity = _state.calculate_velocity(current_jump_gravity, delta)
	
	pass

func reset():
	if _player.anim_tree != null:
		_player.anim_tree.travel("Jump")
	_player.transform = _player.transform.looking_at(_player.global_transform.origin + _state.move_direction, Vector3.UP)
	
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
