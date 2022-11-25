extends Node

class_name Walking


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Running"
var _fall_timer := 0

#onready variables
onready var _state = get_parent()
onready var _player = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass 

func update(delta):
	_player.player_anim.play("Running")
	
	var forwards = _state._camera.global_transform.basis.z
	forwards.y = 0
	forwards = forwards.normalized()
	forwards *= _state.input_direction.z
	var right = _state._camera.global_transform.basis.x * _state.input_direction.x
	
	_state.move_direction = forwards + right
	
	if _state.move_direction.length() > 1:
		_state.move_direction = _state.move_direction.normalized()
	_state.move_direction.y = 0
	
	if _state.move_direction:
		# This insanely long line calculates the vector of the player's direction
		# from the camera's perspective and interpolates to that value by some rotation speed
		var target_direction = _player.transform.looking_at(_player.global_transform.origin + _state.move_direction, Vector3.UP)
		_player.transform = _player.transform.interpolate_with(target_direction, _state.floor_rotation_speed)
	
	if _state._jump_state == _state.jump_pressed:
		_state.update_state("Jump")
		return
	
	if not _player.is_on_floor():
		_fall_timer += 1
		if _fall_timer > _state.coyote_time:
			_state.update_state("Falling")
			return
	else:
		_fall_timer = 0
	
	if not _state.input_direction:
		_state.current_speed *= _state.floor_fricion
		if _state.current_speed < 1:
			_state.update_state("Idle")
			return
	else:
		_state.current_speed += _state.floor_acceleration
	_state.current_speed = clamp(_state.current_speed, 0, _state.max_speed)
	
	_state.velocity = _state.calculate_velocity(_state._fall_gravity, delta)
	pass

