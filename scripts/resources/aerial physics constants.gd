extends Resource
class_name aerial_physics_constants

# Aerial Tech Timers
var shorthop_timer := 0
var shorthop_buffer := 7

var double_jump_timer := 0
var double_jump_buffer := 5

# Air Physics Constants
@export var jump_height := 4.5
@export var jump_time_to_peak := 0.3
@export var jump_time_to_descent := 0.216

@export var jump2_height := 5.1
@export var jump2_time_to_peak := 0.3
@export var jump2_time_to_descent := 0.266

@export var jump3_height := 7.1
@export var jump3_time_to_peak := 0.35
@export var jump3_time_to_descent := 0.36

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

@export var air_friction := 0.99
@export var air_acceleration := 2.0
@export var terminal_velocity := 25.0

var _jump_strength : float = (2.0 * jump_height) / jump_time_to_peak
var _jump_gravity : float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
var _fall_gravity : float = (-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)

var _jump2_strength : float = (2.0 * jump2_height) / jump2_time_to_peak
var _jump2_gravity : float = (-2.0 * jump2_height) / (jump2_time_to_peak * jump2_time_to_peak)
var _fall2_gravity : float = (-2.0 * jump2_height) / (jump2_time_to_descent * jump2_time_to_descent)

var _jump3_strength : float = (2.0 * jump3_height) / jump3_time_to_peak
var _jump3_gravity : float = (-2.0 * jump3_height) / (jump3_time_to_peak * jump3_time_to_peak)
var _fall3_gravity : float = (-2.0 * jump3_height) / (jump3_time_to_descent * jump3_time_to_descent)

var _spin_jump_strength : float = (2.0 * spin_jump_height) / spin_jump_time_to_peak
var _spin_jump_gravity : float = (-2.0 * spin_jump_height) / (spin_jump_time_to_peak * spin_jump_time_to_peak)
var _spin_fall_gravity : float = (-2.0 * spin_jump_height) / (spin_jump_time_to_descent * spin_jump_time_to_descent)

var _side_jump_strength : float = (2.0 * side_jump_height) / side_jump_time_to_peak
var _side_jump_gravity : float = (-2.0 * side_jump_height) / (side_jump_time_to_peak * side_jump_time_to_peak)
var _side_fall_gravity : float = (-2.0 * side_jump_height) / (side_jump_time_to_descent * side_jump_time_to_descent)

var _dive_jump_strength : float = (2.0 * dive_jump_height) / dive_jump_time_to_peak
var _dive_jump_gravity : float = (-2.0 * dive_jump_height) / (dive_jump_time_to_peak * dive_jump_time_to_peak)
var _dive_fall_gravity : float = (-2.0 * dive_jump_height) / (dive_jump_time_to_descent * dive_jump_time_to_descent)

var _rollout_jump_strength : float = (2.0 * rollout_jump_height) / rollout_jump_time_to_peak
var _rollout_jump_gravity : float = (-2.0 * rollout_jump_height) / (rollout_jump_time_to_peak * rollout_jump_time_to_peak)
var _rollout_fall_gravity : float = (-2.0 * rollout_jump_height) / (rollout_jump_time_to_descent * rollout_jump_time_to_descent)

var wall_jump_speed = 12.5
var max_reel_in = 25.0
var dive_speed := 5.0
var spin_skip_strength := 0.7
