class_name PlayerPhysicsConstants extends Resource

@export_category("Grounded movement tuning")
@export var running_acceleration : float = 7.0
@export var max_horizontal_velocity : float = 15.0
@export var max_floor_angle : float = 0.88
@export var default_friction_coefficient : float = 0.8
@export var sideways_friction := 7
@export var forwards_friction := 3


@export_category("Jump Tuning")
@export var air_acceleration : float = 1.0

@export var jump_height := 4.0
@export var jump_time_to_peak := 0.3
@export var jump_time_to_descent := 0.216

@export var jump_2_height := 6.0
@export var jump_2_time_to_peak := 0.35
@export var jump_2_time_to_descent := 0.266

@export var jump_3_height := 4.0
@export var jump_3_time_to_peak := 0.5
@export var jump_3_time_to_descent := 0.316

@export var dive_height := 2.0
@export var dive_time_to_peak := 0.3
@export var dive_time_to_descent := 0.316
@export var dive_speed := 15.0

@export var rollout_height := 1.0
@export var rollout_time_to_peak := 0.35
@export var rollout_time_to_descent := 0.316

var jump_gravity : float
var jump_strength : float
var fall_gravity : float

var jump_2_gravity : float
var jump_2_strength : float
var fall_2_gravity : float

var jump_3_gravity : float
var jump_3_strength : float
var fall_3_gravity : float

var dive_gravity : float
var dive_strength : float
var dive_fall_gravity : float

var rollout_gravity : float
var rollout_strength : float
var rollout_fall_gravity : float

var default_gravity = fall_gravity

var all_jump_strengths := []
var all_jump_gravity := []
var all_fall_gravity := []

func update_constants() -> void:
	jump_gravity = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
	jump_strength = -jump_gravity * jump_time_to_peak
	fall_gravity = (-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)
	
	jump_2_gravity = (-2.0 * jump_2_height) / (jump_2_time_to_peak * jump_2_time_to_peak)
	jump_2_strength = -jump_2_gravity * jump_2_time_to_peak
	fall_2_gravity = (-2.0 * jump_2_height) / (jump_2_time_to_descent * jump_2_time_to_descent)
	
	jump_3_gravity = (-2.0 * jump_3_height) / (jump_3_time_to_peak * jump_3_time_to_peak)
	jump_3_strength = -jump_3_gravity * jump_3_time_to_peak
	fall_3_gravity = (-2.0 * jump_3_height) / (jump_3_time_to_descent * jump_3_time_to_descent)
	
	dive_gravity = (-2.0 * dive_height) / (dive_time_to_peak * dive_time_to_peak)
	dive_strength = -dive_gravity * dive_time_to_peak
	dive_fall_gravity = (-2.0 * dive_height) / (dive_time_to_descent * dive_time_to_descent)
	
	rollout_gravity = (-2.0 * rollout_height) / (rollout_time_to_peak * rollout_time_to_peak)
	rollout_strength = -rollout_gravity * rollout_time_to_peak
	rollout_fall_gravity = (-2.0 * rollout_height) / (rollout_time_to_descent * rollout_time_to_descent)
	
	default_gravity = fall_gravity
	
	all_jump_strengths = [jump_strength, jump_2_strength, jump_3_strength, dive_strength, rollout_strength]
	all_jump_gravity = [jump_gravity, jump_2_gravity, jump_3_gravity, dive_gravity, rollout_gravity]
	all_fall_gravity = [fall_gravity, fall_2_gravity, fall_3_gravity, dive_fall_gravity, rollout_fall_gravity]
