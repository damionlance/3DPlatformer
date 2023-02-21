extends Node

class_name AerialMovement
#warning-ignore:unused_private_class_variable
var backwardsLedgeGrab := false

# Aerial Tech Timers
var shorthop_timer := 0
var shorthop_buffer := 7

var double_jump_timer := 0
var double_jump_buffer := 5

# Jump Logic Variables
var entering_jump_angle : Vector2

# Air Physics Constants
@onready var _jump_strength : float = (2.0 * jump_height) / jump_time_to_peak
@onready var _jump_gravity : float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var _fall_gravity : float = (-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)

@onready var _jump2_strength : float = (2.0 * jump2_height) / jump2_time_to_peak
@onready var _jump2_gravity : float = (-2.0 * jump2_height) / (jump2_time_to_peak * jump2_time_to_peak)
@onready var _fall2_gravity : float = (-2.0 * jump2_height) / (jump2_time_to_descent * jump2_time_to_descent)

@onready var _jump3_strength : float = (2.0 * jump3_height) / jump3_time_to_peak
@onready var _jump3_gravity : float = (-2.0 * jump3_height) / (jump3_time_to_peak * jump3_time_to_peak)
@onready var _fall3_gravity : float = (-2.0 * jump3_height) / (jump3_time_to_descent * jump3_time_to_descent)

@onready var _spin_jump_strength : float = (2.0 * spin_jump_height) / spin_jump_time_to_peak
@onready var _spin_jump_gravity : float = (-2.0 * spin_jump_height) / (spin_jump_time_to_peak * spin_jump_time_to_peak)
@onready var _spin_fall_gravity : float = (-2.0 * spin_jump_height) / (spin_jump_time_to_descent * spin_jump_time_to_descent)

@onready var _side_jump_strength : float = (2.0 * side_jump_height) / side_jump_time_to_peak
@onready var _side_jump_gravity : float = (-2.0 * side_jump_height) / (side_jump_time_to_peak * side_jump_time_to_peak)
@onready var _side_fall_gravity : float = (-2.0 * side_jump_height) / (side_jump_time_to_descent * side_jump_time_to_descent)

@onready var _dive_jump_strength : float = (2.0 * dive_jump_height) / dive_jump_time_to_peak
@onready var _dive_jump_gravity : float = (-2.0 * dive_jump_height) / (dive_jump_time_to_peak * dive_jump_time_to_peak)
@onready var _dive_fall_gravity : float = (-2.0 * dive_jump_height) / (dive_jump_time_to_descent * dive_jump_time_to_descent)

@onready var _rollout_jump_strength : float = (2.0 * rollout_jump_height) / rollout_jump_time_to_peak
@onready var _rollout_jump_gravity : float = (-2.0 * rollout_jump_height) / (rollout_jump_time_to_peak * rollout_jump_time_to_peak)
@onready var _rollout_fall_gravity : float = (-2.0 * rollout_jump_height) / (rollout_jump_time_to_descent * rollout_jump_time_to_descent)

@export var jump_height := 3.1
@export var jump_time_to_peak := 0.3
@export var jump_time_to_descent := 0.216

@export var jump2_height := 5.1
@export var jump2_time_to_peak := 0.3
@export var jump2_time_to_descent := 0.266

@export var jump3_height := 7.1
@export var jump3_time_to_peak := 0.35
@export var jump3_time_to_descent := 0.36

@export var spin_jump_height := 5.1
@export var spin_jump_time_to_peak := .2
@export var spin_jump_time_to_descent := 1.2

@export var side_jump_height := 6.1
@export var side_jump_time_to_peak := .4
@export var side_jump_time_to_descent := .4

@export var dive_jump_height := 2.1
@export var dive_jump_time_to_peak := 0.3
@export var dive_jump_time_to_descent := 0.22

@export var rollout_jump_height := 2.1
@export var rollout_jump_time_to_peak := 0.3
@export var rollout_jump_time_to_descent := 0.3

@export var air_friction := 0.99
@export var air_acceleration := 2.0

var wall_jump_speed = 12.5
var max_reel_in = 25.0
var current_jump_gravity := 0.0
var dive_speed := 2.0
var spin_skip_strength := 0.7
var airdrifting := false

@onready var _player = find_parent("Player")
@onready var _state = find_parent("StateMachine")
@onready var _controller = _player.find_child("Controller")

enum wall_collision {
	noCollision,
	wallSlide,
	ledgeGrab
}

func _ready():
	print(_fall_gravity)

# Helper Functions
func wall_collision_check():
	if _state._jump_state == _state.dive or _player.is_on_floor():
		return wall_collision.noCollision
	var ledgeGrabHit = false
	
	if _state._raycast_left.is_colliding() or _state._raycast_right.is_colliding():
		if abs(_state._raycast_left.get_collision_normal().y) <= .1 or abs(_state._raycast_right.get_collision_normal().y) <= .1:
			if _player.is_on_wall() and _player.velocity.y < 0:
				var prev_horizontal_speed = _player.previous_horizontal_velocity.length()
				if prev_horizontal_speed > 4 and not _player.grappling:
					return wall_collision.wallSlide
	
	else:
		if _state._raycast_middle.is_colliding() and _state.velocity.y < 0:
			ledgeGrabHit = true
		_state._raycast_middle.target_position *= -1
		_state._raycast_middle.force_raycast_update()
		if _state._raycast_middle.is_colliding() and _state.velocity.y < 0:
			ledgeGrabHit = true
		_state._raycast_middle.target_position *= -1
		_state._raycast_middle.force_raycast_update()
	
	var wallHit = false
	
	if ledgeGrabHit:
		_state._raycast_left.target_position *= -1
		_state._raycast_left.force_raycast_update()
		_state._raycast_right.target_position *= -1
		_state._raycast_right.force_raycast_update()
		if _state._raycast_left.is_colliding() or _state._raycast_right.is_colliding():
			wallHit = true
		_state._raycast_left.target_position *= -1
		_state._raycast_right.target_position *= -1
	
	if ledgeGrabHit and not wallHit: return wall_collision.ledgeGrab
	return wall_collision.noCollision

func standard_aerial_drift():
	var relative_angle = entering_jump_angle.dot(_controller.movement_direction)
	_state.move_direction = lerp(_state.move_direction, _state.camera_relative_movement, .03)
	if _controller.movement_direction == Vector2.ZERO:
		_state.current_speed *= air_friction * .98
	elif relative_angle < -.5:
		_state.current_speed *= air_friction
	elif relative_angle > -.5 and relative_angle < .5 and not airdrifting:
		_state.current_speed += 3
		airdrifting = true
	if _player.is_on_wall():
		var wall_normal = _player.get_last_slide_collision().get_normal()
		var cross = wall_normal.cross(Vector3.UP)
		_state.move_direction = _state.move_direction.project(cross)
	pass

func spin_jump_drift():
	if _state._controller.input_strength < .2:
		_state._air_drift_state = _state.not_air_drifting
		_state.current_speed *= air_friction
	
	_state.move_direction = _state.camera_relative_movement
	
	if _player.is_on_wall():
		var position = _player.get_last_slide_collision().get_position() - _player.global_position
		_state.move_direction = (_state.move_direction - (position.normalized() * spin_skip_strength)).normalized()
	
	pass
