extends GroundedMovement


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#private variables
var _state_name = "FloorSlide"
var _keys

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	if _state.current_speed < .1:
		_state.update_state("Running")
		return
	
	if  _state.attempting_jump:
		_state.move_direction = -_state.move_direction
		_state.current_speed = 8
		_state._jump_state = _state.side_flip
		_state.update_state("Jump")
		return
	if not _player.is_on_floor():
		_state._jump_state = _state.jump
		_state.update_state("Falling")
		return
	_state._air_drift_state = _state.not_air_drifting
	_state.current_speed *= .91
	
	_state.velocity = _state.calculate_velocity(0, delta)
	pass

func reset():
	_state._reset_animation_parameters()
	_state.anim_tree["parameters/conditions/skid"] = true
	_state.velocity.y = 0
	_state.move_direction = -(_state.camera_relative_movement)
	_state.current_speed = max_speed
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
