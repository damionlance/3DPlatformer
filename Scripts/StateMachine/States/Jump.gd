extends Node

class_name Jump


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Jump"

#onready variables
onready var _state = get_parent()
onready var _player = get_parent().get_parent()

var entering_angle : Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	_player.player_anim.play("FallALoop")
	
	if not _state.attempting_jump:
		_state._jump_state = _state.jump_released
		_state.velocity.y *= .6
		_state.update_state("Falling")
		return
	
	if _state._jump_state == _state.jump_pressed:
		entering_angle = _state.input_direction
		_state.snap_vector = Vector3.ZERO
		_state.velocity.y = _state._jump_strength
		_state._jump_state = _state.jump_held
	
	if not _state.input_direction or entering_angle.dot(_state.input_direction) < -.5:
		_state.current_speed *= _state.air_friction
	else:
		if _state.current_speed > _state.max_speed:
			_state.current_speed = _state.max_speed
	
	
	_state.velocity = _state.calculate_velocity(_state._jump_gravity, delta)
	
	if _state.velocity.y < 0:
		_state.update_state("Falling")
		return
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
