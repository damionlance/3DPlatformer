extends Node

class_name AerialMovement

# Aerial Movement Variables
var spin_jump_angle := 0.0
var spin_jump_start := Vector2.ZERO
var spin_jump_sign := int(0)
var previous_angle := [0.0, 0.0]
var previous_direction := Vector2.ZERO
var spin_jump_executed := false

# Aerial Tech Timers
var spin_jump_buffer := 90
var spin_jump_timer := 0
var _spin_polling_speed := 1
var _spin_polling_timer := 0
var _wall_jump_buffer := 5
var _wall_jump_timer := 0
var _shorthop_buffer := 7
var _consecutive_jump_timer := 0
var _consecutive_jump_buffer := 1
var coyote_time := 10
var shorthop_timer := 0
var _jump_buffer := 5
var _jump_timer := 5
var _dive_timer := 5

# Jump Logic Variables
var _allow_wall_jump := true
var just_landed = false
var current_jump := 0

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

onready var _state = $"../StateMachine"
onready var _player = $"../../Player"

# Helper Functions
func standard_aerial_drift():
	if abs(_state.input_direction.angle_to(_state.entering_jump_angle)) > (3 * PI)/4:
		# Drift Backwards logic
		_state.current_speed += _state.air_acceleration
		_state._air_drift_state = _state.not_air_drifting
	elif abs(_state.input_direction.angle_to(_state.entering_jump_angle)) > PI/3:
		# Drift Sideways logic
		if (_state._air_drift_state == _state.not_air_drifting):
			_state._air_drift_state = _state.air_drifting
	elif not _state.input_direction:
		_state._air_drift_state = _state.not_air_drifting
		_state.current_speed *= _state.air_friction
	pass

func spin_jump_drift():
	if abs(_state.input_direction.angle_to(_state.entering_jump_angle)) > (3 * PI)/4:
		# Drift Backwards logic
		_state.current_speed += _state.air_acceleration
		_state._air_drift_state = _state.not_air_drifting
	elif abs(_state.input_direction.angle_to(_state.entering_jump_angle)) > PI/3:
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
