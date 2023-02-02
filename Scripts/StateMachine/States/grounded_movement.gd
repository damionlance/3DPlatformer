extends Node

class_name GroundedMovement

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Floor Physics Constants
export var floor_acceleration := 0.3
export var max_speed := 10.0
export var floor_friction := .8
export var floor_rotation_speed :=  .2

export var maximum_lean := PI/6

onready var _state = get_parent()
onready var _player = get_parent().get_parent()
onready var _controller = get_parent().get_parent().get_node("Controller")

var turning := 0
var rotation_scale = 1

func look_forward():
	var lookdir = atan2(-_state.move_direction.x, -_state.move_direction.z)
	_player.rotation.y = lookdir

func lean_into_turns():
	if not _state.move_direction:
		return
	
	var direction = _state.camera_relative_movement
	var lateralAxis = _state.move_direction.cross(Vector3.UP).normalized()
	direction = -(direction.dot(lateralAxis)/lateralAxis.length()) * rotation_scale
	_player.rotation.z = lerp(_player.rotation.z, direction, .15)

func grounded_movement_processing():
	if _controller.movement_direction:
		_state.move_direction = lerp(_state.move_direction, _state.camera_relative_movement, floor_rotation_speed)
		if _state.current_speed != max_speed:
			_state.current_speed = max_speed * _controller.input_strength
	elif _state.current_speed < 1:
		_state.current_speed = 0
		_state.move_direction == Vector3.ZERO
	if _state.current_speed > max_speed * _controller.input_strength:
		_state.current_speed *= floor_friction
	#_player.get_node("lilfella/AnimationPlayer").playback_speed = _state.current_speed/max_speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
