extends Resource
class_name PlayerPhysicsConstants

@export_category("Timers")
var shorthop_timer := 0
var shorthop_buffer := 7

var double_jump_timer := 0
var double_jump_buffer := 5

@export_category("Ground Value Tuning")
@export var running_acceleration := 7.0
@export var slide_acceleration := 20.0
@export var crouching_acceleration := 4.0
@export var max_horizontal_velocity = 15.0
@export var max_walk_speed = 5.0
@export var safe_floor_angle := 0.88
@export var slide_friction := 0.1
var slope_strength := 0.0

@export_category("Wall Physics Tuning")

@export var wall_slide_gravity := 75.0
@export var ledge_hang_speed := 7.0

@export_category("Jump Value Tuning")
@export var jump_height := 4.1
@export var jump_time_to_peak := 0.3
@export var jump_time_to_descent := 0.3

@export var jump2_height := 5.5
@export var jump2_time_to_peak := 0.35
@export var jump2_time_to_descent := 0.35

@export var jump3_height := 7.5
@export var jump3_time_to_peak := 0.4
@export var jump3_time_to_descent := 0.4

@export var spin_jump_height := 5.5
@export var spin_jump_time_to_peak := .7
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

@export var bounce_jump_height := 12.1
@export var bounce_jump_time_to_peak := .55
@export var bounce_jump_time_to_descent := 0.5

@export var _side_jump_velocity : float = 15.0
@export var _damage_launch_velocity : float = 7.5

@export var air_friction := 0.99
@export var air_acceleration := 1000
@export var terminal_velocity := 25.0

var _jump_gravity : float
var _jump_strength : float
var _fall_gravity : float

var _jump2_gravity : float
var _jump2_strength : float
var _fall2_gravity : float

var _jump3_gravity : float
var _jump3_strength : float
var _fall3_gravity : float

var _dive_jump_strength : float
var _dive_jump_gravity : float
var _dive_fall_gravity : float

var _rollout_jump_strength : float
var _rollout_jump_gravity : float
var _rollout_fall_gravity : float

var _spin_jump_strength : float
var _spin_jump_gravity : float
var _spin_fall_gravity : float

var _side_jump_strength : float
var _side_jump_gravity : float
var _side_fall_gravity : float

var _bounce_jump_strength : float
var _bounce_jump_gravity : float
var _bounce_fall_gravity : float

var jump_strength
var jump_gravity
var fall_gravity
func _ready():
	_jump_strength = (2 * jump_height) / jump_time_to_peak
	_jump_gravity = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
	_fall_gravity  = (-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)
	
	_jump2_strength = (2 * jump2_height) / jump2_time_to_peak
	_jump2_gravity = (-2.0 * jump2_height) / (jump2_time_to_peak * jump2_time_to_peak)
	_fall2_gravity = (-2.0 * jump2_height) / (jump2_time_to_descent * jump2_time_to_descent)
	
	_jump3_strength = (2 * jump3_height) / jump3_time_to_peak
	_jump3_gravity = (-2.0 * jump3_height) / (jump3_time_to_peak * jump3_time_to_peak)
	_fall3_gravity = (-2.0 * jump3_height) / (jump3_time_to_descent * jump3_time_to_descent)
	
	_dive_jump_strength = (2.0 * dive_jump_height) / dive_jump_time_to_peak
	_dive_jump_gravity = (-2.0 * dive_jump_height) / (dive_jump_time_to_peak * dive_jump_time_to_peak)
	_dive_fall_gravity = (-2.0 * dive_jump_height) / (dive_jump_time_to_descent * dive_jump_time_to_descent)
	
	_rollout_jump_strength = (2.0 * rollout_jump_height) / rollout_jump_time_to_peak
	_rollout_jump_gravity = (-2.0 * rollout_jump_height) / (rollout_jump_time_to_peak * rollout_jump_time_to_peak)
	_rollout_fall_gravity = (-2.0 * rollout_jump_height) / (rollout_jump_time_to_descent * rollout_jump_time_to_descent)
	
	_spin_jump_strength = (2.0 * spin_jump_height) / spin_jump_time_to_peak
	_spin_jump_gravity = (-2.0 * spin_jump_height) / (spin_jump_time_to_peak * spin_jump_time_to_peak)
	_spin_fall_gravity = (-2.0 * spin_jump_height) / (spin_jump_time_to_descent * spin_jump_time_to_descent)
	
	_side_jump_strength = (2.0 * side_jump_height) / side_jump_time_to_peak
	_side_jump_gravity = (-2.0 * side_jump_height) / (side_jump_time_to_peak * side_jump_time_to_peak)
	_side_fall_gravity = (-2.0 * side_jump_height) / (side_jump_time_to_descent * side_jump_time_to_descent)
	
	_bounce_jump_strength = (2.0 * bounce_jump_height) / bounce_jump_time_to_peak
	_bounce_jump_gravity = (-2.0 * bounce_jump_height) / (bounce_jump_time_to_peak * bounce_jump_time_to_peak)
	_bounce_fall_gravity = (-2.0 * bounce_jump_height) / (bounce_jump_time_to_descent * bounce_jump_time_to_descent)

	jump_strength = [_jump_strength, _jump2_strength, _jump3_strength, _dive_jump_strength, _rollout_jump_strength, _spin_jump_strength, _side_jump_strength, _jump_strength, _bounce_jump_strength]
	jump_gravity = [_jump_gravity, _jump2_gravity, _jump3_gravity, _dive_jump_gravity, _rollout_jump_gravity, _spin_jump_gravity, _side_jump_gravity, _jump_gravity, _bounce_jump_gravity]
	fall_gravity = [_fall_gravity, _fall2_gravity, _fall3_gravity, _dive_fall_gravity, _rollout_fall_gravity, _spin_fall_gravity, _side_fall_gravity, _fall_gravity, _bounce_fall_gravity]
	pass




var wall_jump_speed = 12.5
var max_reel_in = 25.0
var dive_speed := 5.0
var spin_skip_strength := 0.7
