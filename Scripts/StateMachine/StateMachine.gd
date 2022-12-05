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
var _allow_wall_jump := true
var _wall_jump_buffer := 5
var _wall_jump_timer := 0
export var _shorthop_buffer := 7

var just_landed = false

var _consecutive_jump_timer := 0
var _consecutive_jump_buffer := 1

var _jump_buffer := 5
var _jump_timer := 5
var _dive_timer := 5

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

export var air_friction := 0.99
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

var _current_state

# Player Jump Flags
var _jump_state := 2
enum {
	jump_pressed = 0,
	jump_held = 1,
	jump_released = 2,
	allow_jump = 3
}

var _dive_state := 2
enum {
	dive_pressed = 0,
	dive_held = 1,
	dive_released = 2,
	allow_dive = 3
}

var _air_drift_state
enum {
	not_air_drifting,
	air_drifting
}

var attempting_jump := false
var attempting_dive := false
var is_on_floor := false

var input_direction :=  Vector3.ZERO
var move_direction := Vector3.ZERO
var character_model_direction := Vector2.ZERO
var current_dir := Vector2(0,1)
var current_speed = 0

# Used for calculating camera relative inputs.
var forwards := Vector3.ZERO
var right := Vector3.ZERO

#onready variables
onready var _player = get_parent()
onready var _camera = $"../CameraPivot"
onready var _raycast_left = _player.get_node("WallRayLeft")
onready var _raycast_right = _player.get_node("WallRayRight")

# Called when the node enters the scene tree for the first time.
func _ready():
	update_state("Falling")
	pass # Replace with function body.

func _process(delta):
	input_handling()
	
	jump_state_handling()
	_current_state.update(delta)
	velocity = _player.move_and_slide_with_snap(velocity, snap_vector, Vector3.UP, true)

func input_handling():	
	var controller_input = Input.get_vector("Left", "Right", "Backward", "Forward")
	input_direction.x = controller_input.x
	input_direction.z = -controller_input.y
	attempting_jump = Input.is_action_pressed("Jump")
	attempting_dive = Input.is_action_pressed("DiveButton")
	
	forwards = _camera.global_transform.basis.z
	forwards.y = 0
	forwards = forwards.normalized()
	forwards *= input_direction.z
	right = _camera.global_transform.basis.x * input_direction.x
	
	spin_jump_handling(controller_input)
	

func update_state( new_state ):
	_current_state = state_dictionary[new_state]
	_current_state.reset()

func calculate_velocity(gravity: float, delta) -> Vector3:
	var new_velocity = move_direction * current_speed
	new_velocity.y += velocity.y + gravity * delta
	return new_velocity

################################################################################
############################ HELPER FUNCTIONS ##################################
################################################################################

func jump_state_handling():
	
	if not _allow_wall_jump:
		if _wall_jump_timer == _wall_jump_buffer:
			_allow_wall_jump = true
			_wall_jump_timer = 0
		else:
			_wall_jump_timer += 1
	
	if just_landed:
		_consecutive_jump_timer += 1
		if _consecutive_jump_buffer == _consecutive_jump_timer:
			just_landed = false
			_consecutive_jump_timer = 0
	
	# Spin Jump Buffer Handling
	if spin_jump_executed:
		spin_jump_timer += 1
		if spin_jump_timer == spin_jump_buffer:
			spin_jump_executed = false
			spin_jump_timer = 0
	
	var resetting_collision = false
	if _player.is_on_floor() or (_player.is_on_wall() and _allow_wall_jump):
		resetting_collision = true
	
	# Jump State Handling
	if attempting_jump and _jump_state == allow_jump:
		_jump_state = jump_pressed
		_jump_timer = _jump_buffer
	elif attempting_jump and not resetting_collision:
		_jump_state = jump_held
	elif resetting_collision and (_jump_timer < _jump_buffer or not attempting_jump):
		_jump_state = allow_jump
	elif not attempting_jump:
		_jump_state = jump_released
		_jump_timer = 0
	
	if attempting_jump and not (_player.is_on_floor() or _player.is_on_wall()):
		if _jump_state == jump_held:
			_jump_timer += 1
	
	if attempting_dive and _dive_state == allow_dive:
		_dive_state = dive_pressed
		_jump_timer = _jump_buffer
	elif attempting_dive and not resetting_collision:
		_dive_state = dive_held
	elif resetting_collision and (_dive_timer < _jump_buffer or not attempting_dive):
		_dive_state = allow_dive
	elif not attempting_dive:
		_dive_state = dive_released
		_dive_timer = 0
	
	if attempting_dive and not (_player.is_on_floor() or _player.is_on_wall()):
		if _dive_state == dive_held:
			_dive_timer += 1

func spin_jump_handling(controller_input: Vector2):
	if spin_jump_executed:
		spin_jump_timer += 1
		if spin_jump_buffer == spin_jump_timer:
			spin_jump_executed = false
			spin_jump_timer = 0
			spin_jump_angle = 0
			spin_jump_start = Vector2.ZERO
	
	if controller_input != Vector2.ZERO:
		_spin_polling_timer = 0
		var lengths = previous_direction.length() * controller_input.length()
		previous_angle[1] = previous_angle[0]
		
		if lengths:
			previous_angle[0] = controller_input.angle()
			if previous_angle[0]<0:
				previous_angle[0] += 2*PI
		else:
			previous_angle[0] = previous_angle[1]
		if spin_jump_start.length() < .01:
			spin_jump_start = controller_input
			spin_jump_angle = 0
		elif abs(previous_angle[0]-previous_angle[1]) > .02 and sign(previous_angle[0]-previous_angle[1]) != spin_jump_sign:
			if not (previous_angle[1] > deg2rad(350) and previous_angle[0] > 0):
				spin_jump_angle = 0
				spin_jump_start = controller_input
				spin_jump_sign = sign(previous_angle[0]-previous_angle[1])
		else:
			spin_jump_angle += previous_angle[0] - previous_angle[1]
			if abs(spin_jump_angle) > 4 * PI / 3:
				spin_jump_executed = true
		previous_direction = controller_input

func wall_jump_collision_check():
	if _raycast_left.is_colliding() or _raycast_right.is_colliding():
		if abs(_raycast_left.get_collision_normal().y) > 0 or abs(_raycast_right.get_collision_normal().y) > 0:
			if _player.is_on_wall():
				var horizontalVelocity = Vector3(velocity.x, 0, velocity.z)
				if horizontalVelocity.length() > max_speed/2:
					return true
	return false
