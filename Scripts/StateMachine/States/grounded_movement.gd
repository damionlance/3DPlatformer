extends Node

class_name GroundedMovement

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Floor Physics Constants
export var floor_acceleration := 0.3
export var max_speed := 10
export var floor_friction := .8
export var floor_rotation_speed :=  .3

onready var _state = get_parent()
onready var _player = get_parent().get_parent()
onready var _controller = get_parent().get_node("Controller")


func grounded_movement_processing():
	_state.move_direction = lerp(_state.move_direction, _state.camera_relative_movement, floor_rotation_speed)
	
	if _state.current_speed > max_speed:
		_state.current_speed = lerp(_state.current_speed, max_speed, .25)
	if _state.current_speed > max_speed * _controller.input_strength:
		_state.current_speed -= .5
	else:
		_state.current_speed = max_speed * _controller.input_strength

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
