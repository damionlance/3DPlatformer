extends Node

class_name GroundedMovement

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Floor Physics Constants
export var floor_acceleration := 0.3
export var max_speed := 10
export var floor_friction := .8
export var floor_rotation_speed :=  .2

onready var _state = get_parent()
onready var _player = get_parent().get_parent()
onready var _controller = get_parent().get_node("Controller")


func grounded_movement_processing():
	if _controller.movement_direction:
		_state.move_direction = lerp(_state.move_direction, _state.camera_relative_movement, floor_rotation_speed)
		_state.current_speed += floor_acceleration
	elif _state.current_speed < 1:
		_state.current_speed = 0
		_state.move_direction == Vector3.ZERO
	if _state.current_speed > max_speed * _controller.input_strength:
		_state.current_speed *= floor_friction
	#_player.get_node("lilfella/AnimationPlayer").playback_speed = _state.current_speed/max_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
