extends Node

#public variables
var state_dictionary : Dictionary

#Player Physics Variables

var velocity :=  Vector3.ZERO
var snap_vector := Vector3.DOWN

# Air Physics Constants
export var jump_height := 3.1
export var jump_time_to_peak := 0.3
export var jump_time_to_descent := 0.216
export var air_friction := 0.9
export var air_acceleration := 2.0
export var coyote_time := 10

# Jump parameter Constants calculated at runtime
onready var _jump_strength : float = (2.0 * jump_height) / jump_time_to_peak
onready var _jump_gravity : float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
onready var _fall_gravity : float = (-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)

# Floor Physics Constants
export var floor_acceleration := 0.5
export var max_speed := 10.0
export var floor_fricion := .8
export var floor_rotation_speed :=  .2

var current_jump = 0
var current_speed = 0
var current_dir := Vector2(0,1)
var character_model_direction := Vector2.ZERO

var entering_jump_angle := Vector3.ZERO

var _current_state

# Player Jump Flags
var _jump_state := 2
enum {
	jump_pressed = 0,
	jump_held = 1,
	jump_released = 2,
	allow_jump = 3
}
var _air_drift_state
enum {
	not_air_drifting,
	air_drifting
}

var attempting_jump := false
var is_on_floor := false

var input_direction :=  Vector3.ZERO
var move_direction := Vector3.ZERO

#onready variables
onready var _player = get_parent()
onready var _camera = get_parent().get_node("SpringArm")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	input_handling()
	
	if attempting_jump and _jump_state == allow_jump:
		_jump_state = jump_pressed
	elif not attempting_jump and _jump_state != jump_released:
		_jump_state = jump_released
	if _jump_state == jump_released and _player.is_on_floor():
		_jump_state = allow_jump
	
	_current_state.update(delta)
	
	velocity = _player.move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)

func input_handling():
	input_direction.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	input_direction.z = Input.get_action_strength("Backward") - Input.get_action_strength("Forward")
	attempting_jump = Input.is_action_pressed("Jump")

func update_state( new_state ):
	_current_state = state_dictionary[new_state]


func calculate_velocity(gravity: float, delta) -> Vector3:
	var new_velocity = move_direction * current_speed
	new_velocity.y += velocity.y + gravity * delta
	return new_velocity
