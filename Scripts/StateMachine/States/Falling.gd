extends Node

class_name Falling


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Falling"

#onready variables
onready var _state = get_parent()
onready var _player = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	_player.player_anim.play("FallALoop")
	if _player.is_on_floor():
		_state.snap_vector = Vector3.DOWN
		_state.update_state("Idle")
		return
	
	if _state.move_direction.length() > 1:
		_state.move_direction = _state.move_direction.normalized()
	_state.move_direction.y = 0
	
	_state.snap_vector = Vector3.ZERO
	_state.current_jump += _state._fall_gravity * delta
	if not _state.input_direction:
		_state.current_speed *= _state.air_friction
	else:
		if _state.current_speed > _state.max_speed:
			_state.current_speed = _state.max_speed
	
	
	_state.velocity = _state.calculate_velocity(_state._fall_gravity, delta)
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
