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
var previous_move_direction := Vector3.ZERO
var strength_of_slope := 0.0
var maximum_slope := PI/6

func look_forward():
	var lookdir = atan2(-_state.move_direction.x, -_state.move_direction.z)
	_player.rotation.y = lookdir

func lean_into_turns():
	if _player.is_on_wall():
		_player.rotation.z = 0
		return
	if _state.move_direction == Vector3.ZERO:
		return
	
	var direction = _state.camera_relative_movement
	var lateralAxis = _state.move_direction.cross(Vector3.UP).normalized()
	direction = -(direction.dot(lateralAxis)/lateralAxis.length()) * rotation_scale
	_player.rotation.z = lerp(_player.rotation.z, direction, .15)

func grounded_movement_processing():
	#print("Grounded Movement Processing")
	#print(_player.velocity)
	#print("Move Direction 1: ", _state.move_direction)
	_state.consecutive_stationary_wall_jump = 0

	if _player.get_floor_angle() > maximum_slope:
		strength_of_slope += .001
	else:
		strength_of_slope = 0.00
	var ground = ground_probe.get_collider()
	if ground:
		if ground.get("friction"):
			_state.ground_friction = ground.friction
	if _controller.movement_direction:
		if previous_move_direction.length() <= _state.move_direction.length():
			_state.move_direction = lerp(_state.move_direction, _state.camera_relative_movement, floor_rotation_speed)
			_state.current_speed = lerp(float(_state.current_speed), (max_speed * _controller.input_strength), _state.ground_friction)
			#print("Move Direction 2: ", _state.move_direction)
	elif _state.current_speed < 1:
		_state.current_speed = 0
	else:
		_state.current_speed *= 1 - _state.ground_friction
	
	if _player.is_on_floor():
		var floor_normal = _player.get_last_slide_collision()
		if floor_normal:
			floor_normal = floor_normal.get_normal()
			floor_normal.y = 0
			_state.move_direction = _state.move_direction.lerp(Vector3(floor_normal.x, 0, floor_normal.z), strength_of_slope)	
			#print("Move Direction 3: ", _state.move_direction)
	previous_move_direction = _state.move_direction
	#print(_player.velocity)
