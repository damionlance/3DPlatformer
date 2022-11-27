extends Node

#public variables
var state_dictionary : Dictionary

#Player Physics Variables

var velocity :=  Vector3.ZERO
var snap_vector := Vector3.DOWN

# Special inputs tracking
var spin_jump_angle := 0.0
var spin_jump_start := Vector2.ZERO
var spin_jump_sign := int(0)
var previous_angle := [0.0, 0.0]
var previous_direction := Vector2.ZERO
var spin_jump_executed := false
export var spin_jump_buffer := 90
var spin_jump_timer := 0
export var _spin_polling_speed := 1
var _spin_polling_timer := 0

var just_landed = false

var _jump_timer := 0
var _jump_buffer := 30

# Air Physics Constants
export var jump_height := 3.1
export var jump_time_to_peak := 0.3
export var jump_time_to_descent := 0.216

export var jump2_height := 5.1
export var jump2_time_to_peak := 0.35
export var jump2_time_to_descent := 0.266

export var spin_jump_height := 5.1
export var spin_jump_time_to_peak := .4
export var spin_jump_time_to_descent := 1.0

export var air_friction := 0.9
export var air_acceleration := 2.0
export var coyote_time := 10

# Jump parameter Constants calculated at runtime
onready var _jump_strength : float = (2.0 * jump_height) / jump_time_to_peak
onready var _jump_gravity : float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
onready var _fall_gravity : float = (-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)

onready var _jump2_strength : float = (2.0 * jump2_height) / jump2_time_to_peak
onready var _jump2_gravity : float = (-2.0 * jump2_height) / (jump2_time_to_peak * jump2_time_to_peak)
onready var _fall2_gravity : float = (-2.0 * jump2_height) / (jump2_time_to_descent * jump2_time_to_descent)

onready var _spin_jump_strength : float = (2.0 * spin_jump_height) / spin_jump_time_to_peak
onready var _spin_jump_gravity : float = (-2.0 * spin_jump_height) / (spin_jump_time_to_peak * spin_jump_time_to_peak)
onready var _spin_fall_gravity : float = (-2.0 * spin_jump_height) / (spin_jump_time_to_descent * spin_jump_time_to_descent)

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
onready var _camera = $"../CameraPivot"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	input_handling()
	
	if just_landed:
		_jump_timer += 1
		if _jump_buffer == _jump_timer:
			just_landed = false
			_jump_timer = 0
	
	if spin_jump_executed:
		spin_jump_timer += 1
		if spin_jump_timer == spin_jump_buffer:
			spin_jump_executed = false
			spin_jump_timer = 0
	if attempting_jump and _jump_state == allow_jump:
		_jump_state = jump_pressed
	if attempting_jump and jump_pressed:
		_jump_state = jump_held
	elif not attempting_jump and _jump_state != jump_released:
		_jump_state = jump_released
	if not attempting_jump and _player.is_on_floor():
		_jump_state = allow_jump
	
	_current_state.update(delta)
	
	velocity = _player.move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)

func input_handling():
	var controller_input = Input.get_vector("Left", "Right", "Forward", "Backward")
	input_direction.x = controller_input.x
	input_direction.z = controller_input.y
	attempting_jump = Input.is_action_pressed("Jump")
	if spin_jump_executed:
		spin_jump_timer += 1
		if spin_jump_buffer == spin_jump_timer:
			spin_jump_executed = false
			spin_jump_timer = 0
	if controller_input != Vector2.ZERO:
		_spin_polling_timer = 0
		var lengths = previous_direction.length() * controller_input.length()
		previous_angle[1] = previous_angle[0]
	
		if lengths:
			previous_angle[0] += controller_input.angle()
		else:
			previous_angle[0] = previous_angle[1]
		if spin_jump_start == Vector2.ZERO:
			spin_jump_start = controller_input
		elif abs(previous_angle[1]-previous_angle[0]) > .2 and sign(previous_angle[1]-previous_angle[0]) != spin_jump_sign:
			spin_jump_angle = 0
			spin_jump_start = controller_input
			spin_jump_sign = sign(previous_angle[1]-previous_angle[0])
		else:
			spin_jump_angle += previous_angle[0] - previous_angle[1]
			if abs(spin_jump_angle) > 3 *PI / 2:
				spin_jump_executed = true
				spin_jump_start == Vector2.ZERO
				spin_jump_angle = 0
		previous_direction = controller_input

func update_state( new_state ):
	_current_state = state_dictionary[new_state]


func calculate_velocity(gravity: float, delta) -> Vector3:
	var new_velocity = move_direction * current_speed
	new_velocity.y += velocity.y + gravity * delta
	return new_velocity
