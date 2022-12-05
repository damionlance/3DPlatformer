extends Node

class_name GroundedMovement

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Floor Physics Constants
export var floor_acceleration := 0.5
export var max_speed := 10.0
export var floor_fricion := .8
export var floor_rotation_speed :=  .2

onready var _state = get_parent()
onready var _player = get_parent().get_parent()


func grounded_movement_processing():
	_state.move_direction = (_state.forwards + _state.right).normalized()
	if _state.current_speed > max_speed:
		_state.current_speed = lerp(_state.current_speed, max_speed, .25)
	elif _state.current_speed + floor_acceleration > max_speed * _state.input_direction.length():
		_state.current_speed = max_speed * _state.input_direction.length()
	else:
		_state.current_speed += floor_acceleration

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
