extends Node

class_name AerialMovement

# Aerial Tech Timers
var shorthop_timer := 0
var shorthop_buffer := 7

var double_jump_timer := 0
var double_jump_buffer := 5

# Jump Logic Variables
var current_jump := 0
var entering_jump_angle := Vector2.ZERO

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

onready var _side_jump_strength : float = (2.0 * side_jump_height) / side_jump_time_to_peak
onready var _side_jump_gravity : float = (-2.0 * side_jump_height) / (side_jump_time_to_peak * side_jump_time_to_peak)
onready var _side_fall_gravity : float = (-2.0 * side_jump_height) / (side_jump_time_to_descent * side_jump_time_to_descent)

export var jump_height := 3.1
export var jump_time_to_peak := 0.3
export var jump_time_to_descent := 0.216

export var jump2_height := 5.1
export var jump2_time_to_peak := 0.35
export var jump2_time_to_descent := 0.266

export var spin_jump_height := 5.1
export var spin_jump_time_to_peak := .4
export var spin_jump_time_to_descent := 1.0

export var side_jump_height := 7.1
export var side_jump_time_to_peak := .4
export var side_jump_time_to_descent := .4

export var air_friction := 0.99
export var air_acceleration := 2.0

var wall_jump_speed = 12.5
var max_reel_in = 25

var dive_speed := 6

onready var _state = get_parent()
onready var _player = get_parent().get_parent()
onready var _controller = get_parent().get_parent().get_node("Controller")

enum wall_collision {
	noCollision,
	wallSlide,
	ledgeGrab
}

func _ready():
	_state = get_parent()

# Helper Functions
func wall_collision_check():
	if _state._raycast_left.colliding or _state._raycast_right.colliding:
		if abs(_state._raycast_left.get_collision_normal().y) > 0 or abs(_state._raycast_right.get_collision_normal().y) > 0:
			if _player.is_on_wall():
				var horizontalVelocity = Vector3(_state.velocity.x, 0, _state.velocity.z)
				if horizontalVelocity.length() > 1 or _player.grappling:
					return wall_collision.wallSlide
	elif _state._raycast_middle.colliding and _state.velocity.y < 0:
		return wall_collision.ledgeGrab
	return wall_collision.noCollision

func _process(_delta):
	if _state.just_landed:
		double_jump_timer += 1
		if double_jump_buffer == double_jump_timer:
			double_jump_timer = 0
			_state.just_landed = false

func standard_aerial_drift():
	var relative_angle = entering_jump_angle.dot(_controller.movement_direction)
	if not _controller.movement_direction:
		_state.current_speed *= air_friction
	elif relative_angle < -.5:
		_state.current_speed *= air_friction * .98
		_state.move_direction = lerp(_state.move_direction, _state.camera_relative_movement, .001)
	elif entering_jump_angle == Vector2.ZERO and _controller.movement_direction:
		_state.current_speed += .2
		_state.move_direction = lerp(_state.move_direction, _state.camera_relative_movement, .1)
	pass



func spin_jump_drift():
	if _state._controller.input_strength < .2:
		_state._air_drift_state = _state.not_air_drifting
		_state.current_speed *= air_friction
	
	_state.move_direction = _state.camera_relative_movement
	pass
