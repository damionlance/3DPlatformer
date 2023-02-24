extends Node

class_name GroundedMovement

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Floor Physics Constants
@export var floor_acceleration := 0.3
@export var max_speed := 11.5
@export var floor_rotation_speed :=  .2
@export var maximum_lean := PI/6

@onready var _player = find_parent("Player")
@onready var _state = find_parent("StateMachine")
@onready var _controller = _player.find_child("Controller")
@onready var ground_probe := _player.find_child("Ground Probe")

var turning := 0
var rotation_scale = 1
var previous_move_direction

func look_forward():
	var lookdir = atan2(-_state.move_direction.x, -_state.move_direction.z)
	_player.rotation.y = lookdir

func lean_into_turns():
	if _state.move_direction == Vector3.ZERO:
		return
	
	var direction = _state.camera_relative_movement
	var lateralAxis = _state.move_direction.cross(Vector3.UP).normalized()
	direction = -(direction.dot(lateralAxis)/lateralAxis.length()) * rotation_scale
	_player.rotation.z = lerp(_player.rotation.z, direction, .15)

func grounded_movement_processing():
	var ground = ground_probe.get_collider()
	if ground:
		if ground.get("friction"):
			_state.ground_friction = ground.friction
	previous_move_direction = _state.move_direction
	if _controller.movement_direction:
		_state.move_direction = lerp(_state.move_direction, _state.camera_relative_movement, floor_rotation_speed)
		_state.current_speed = lerp(float(_state.current_speed), (max_speed * _controller.input_strength), _state.ground_friction)
	elif _state.current_speed < 1:
		_state.current_speed = 0
	else:
		_state.current_speed *= 1 - _state.ground_friction
	if _player.is_on_wall():
		var wall_normal = _player.get_last_slide_collision().get_normal()
		var cross = wall_normal.cross(Vector3.UP)
		_state.move_direction = _state.move_direction.project(cross)
	if _player.is_on_floor():
		var floor_normal = _player.get_last_slide_collision().get_normal()
		_state.move_direction += (1-_state.ground_friction) * Vector3(floor_normal.x, 0, floor_normal.z)
		_state.move_direction = _state.move_direction.normalized()
		print(_state.move_direction.length())
