extends Node

class_name AerialMovement

# Aerial Tech Timers
var shorthop_timer := 0

# Jump Logic Variables
var current_jump := 0
var entering_jump_angle := Vector3.ZERO

# Air Physics Constants
onready var _jump_strength : float = (2.0 * jump_height) / jump_time_to_peak
onready var _jump_gravity : float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
onready var _fall_gravity : float = (-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)

onready var _jump2_strength : float = (2.0 * jump2_height) / jump2_time_to_peak
onready var _jump2_gravity : float = (-2.0 * jump2_height) / (jump2_time_to_peak * jump2_time_to_peak)
onready var _fall2_gravity : float = (-2.0 * jump2_height) / (jump2_time_to_descent * jump2_time_to_descent)

onready var _spin_jump_strength : float = (2.0 * spin_jump_height) / spin_jump_time_to_peak
onready var _spin_jump_gravity : float = (-2.0 * spin_jump_height) / (spin_jump_time_to_peak * spin_jump_time_to_peak)
onready var _spin_fall_gravity : float = (-2.0 * spin_jump_height) / (spin_jump_time_to_descent * spin_jump_time_to_descent)

export var jump_height := 3.1
export var jump_time_to_peak := 0.3
export var jump_time_to_descent := 0.216

export var jump2_height := 5.1
export var jump2_time_to_peak := 0.35
export var jump2_time_to_descent := 0.266

export var spin_jump_height := 5.1
export var spin_jump_time_to_peak := .4
export var spin_jump_time_to_descent := 1.0

export var air_friction := 0.99
export var air_acceleration := 2.0

onready var _state = get_parent()
onready var _player = get_parent().get_parent()

# Helper Functions
func wall_jump_collision_check():
	if _state._raycast_left.is_colliding() or _state._raycast_right.is_colliding():
		if abs(_state._raycast_left.get_collision_normal().y) > 0 or abs(_state._raycast_right.get_collision_normal().y) > 0:
			if _player.is_on_wall():
				var horizontalVelocity = Vector3(_state.velocity.x, 0, _state.velocity.z)
				if horizontalVelocity.length() > _state.max_speed/2:
					return true
	return false

func standard_aerial_drift():
	if abs(_state.input_direction.angle_to(entering_jump_angle)) > (3 * PI)/4:
		# Drift Backwards logic
		_state.current_speed += _state.air_acceleration
		_state._air_drift_state = _state.not_air_drifting
	elif abs(_state.input_direction.angle_to(entering_jump_angle)) > PI/3:
		# Drift Sideways logic
		if (_state._air_drift_state == _state.not_air_drifting):
			_state._air_drift_state = _state.air_drifting
	elif not _state.input_direction:
		_state._air_drift_state = _state.not_air_drifting
		_state.current_speed *= air_friction
	pass

func spin_jump_drift():
	if abs(_state.input_direction.angle_to(entering_jump_angle)) > (3 * PI)/4:
		# Drift Backwards logic
		_state.current_speed += _state.air_acceleration
		_state._air_drift_state = _state.not_air_drifting
	elif abs(_state.input_direction.angle_to(entering_jump_angle)) > PI/3:
		# Drift Sideways logic
		if (_state._air_drift_state == _state.not_air_drifting):
			_state._air_drift_state = _state.air_drifting
	elif not _state.input_direction:
		_state._air_drift_state = _state.not_air_drifting
		_state.current_speed *= _state.air_friction
	if _state.current_speed > _state.max_speed:
		_state.current_speed = _state.max_speed
	
	_state.move_direction = _state.forwards + _state.right
	pass
