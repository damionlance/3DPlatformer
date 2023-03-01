extends Node

#public variables
var state_dictionary : Dictionary
var level_loaded : bool

var halt_frames : Dictionary

#Player Physics Variables
var velocity :=  Vector3.ZERO
var prev_velocity := Vector3.ZERO
var snap_vector := Vector3.DOWN
var grapple_position = Vector3.ZERO
var current_jump := 0
var terminal_velocity := 50

# Special inputs tracking
var previous_angle := [0.0, 0.0]
var previous_direction := Vector2.ZERO
var spin_jump_executed := false
var _wall_jump_buffer := 5
var _wall_jump_timer := 0
@export var _shorthop_buffer := 0
var _shorthop_timer := 7
var pivot_buffer = []
var pivot_buffer_size := 10

var just_landed = false

var _consecutive_jump_timer := 0
var _consecutive_jump_buffer := 5

var _jump_buffer := 5
var _jump_timer := 5
var _dive_timer := 5

var consecutive_stationary_wall_jump := 0

@export var coyote_time := 10


var _current_state = null

var _air_drift_state
enum {
	not_air_drifting,
	air_drifting
}
var _jump_state
enum {
	no_jump,
	jump,
	jump2,
	jump3,
	spin_jump,
	side_flip,
	dive,
	rollout,
	popper_bounce,
	ground_pound,
	quick_getup
}

var attempting_jump := false
var allow_jump := false
var attempting_dive := false
var allow_dive := true
var spin_allowed := false
var spin_timer := 0
var spin_buffer := 30
var is_on_floor := false
var attempting_throw := false

var camera_relative_movement := Vector3.ZERO
var move_direction := Vector3.ZERO
var current_dir := Vector3.ZERO
var desired_speed = 0.0
var current_speed = 0.0

# Used for calculating camera relative inputs.
var forwards := Vector3.ZERO
var right := Vector3.ZERO

var ground_friction := 1.0

#onready variables
@onready var _player = get_parent()
@onready var _camera = $"../CameraPivot"
@onready var _raycast_left = _player.get_node("WallRayLeft")
@onready var _raycast_right = _player.get_node("WallRayRight")
@onready var _raycast_middle = _player.get_node("WallRayMiddle")
@onready var _controller = $"../Controller"
@onready var _skeleton = $"../lilfella/Armature/Skeleton3D"
@onready var _softspot_detector = $"../SoftSpot Detector"

#signals
signal throw_fella

var enemyBounce := false
var bounceTimer := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	level_loaded = false
	pivot_buffer.resize(pivot_buffer_size)
	state_dictionary.is_empty()
	pass # Replace with function body.

func _process(delta):
	if not level_loaded:
		return
	if _current_state == null:
		_jump_state = jump
		update_state("Falling")
	if not enemyBounce:
		for area in _softspot_detector.get_overlapping_areas():
			if area.name == "SoftSpot":
				current_jump = 1
				_jump_state = 1
				update_state("Jump")
	input_handling()
	_current_state.update(delta)
	_player.update_physics_data(velocity, snap_vector)

func input_handling():
	forwards = _camera.global_transform.basis.z
	forwards.y = 0
	forwards = forwards.normalized()
	forwards *= _controller.movement_direction.y
	right = _camera.global_transform.basis.x * _controller.movement_direction.x
	camera_relative_movement = -forwards + -right
	
	var resetting_collision = false
	var jump_released_since_jump = false
	if _player.is_on_floor() or _player.is_on_wall():
		resetting_collision = true
		if _consecutive_jump_timer < _consecutive_jump_buffer:
			just_landed = true
			_consecutive_jump_timer += 1
		else:
			just_landed = false
			_consecutive_jump_timer = _consecutive_jump_buffer
	else:
		_consecutive_jump_timer = 0
	
	
	if (resetting_collision):
		allow_jump = true
	else:
		allow_jump = false
	
	if _controller.spin_entered:
		spin_allowed = true
	if spin_allowed:
		spin_timer += 1
		if spin_timer == spin_buffer:
			spin_allowed = false
			spin_timer = 0
	
	if _controller._jump_state == _controller.jump_pressed and allow_jump:
		attempting_jump = true
	elif _controller._jump_state == _controller.jump_held and _jump_buffer < _jump_timer:
		attempting_jump = true
		_jump_buffer += 1
	else: 
		attempting_jump = false
	if _controller._dive_state == _controller.dive_pressed and allow_dive:
		attempting_dive = true
	else: 
		attempting_dive = false
	
	if _controller._throw_state == _controller.throw_pressed:
		attempting_throw = true
	elif _controller._throw_state == _controller.throw_held:
		attempting_throw = false
	else:
		attempting_throw = false
	
	if (_controller._jump_state == _controller.jump_released and
		_controller._dive_state == _controller.dive_released):
			_jump_buffer = 0

func update_state( new_state ):
	_current_state = state_dictionary[new_state]
	_current_state.reset()

func calculate_velocity(gravity: float, delta) -> Vector3:
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	var new_velocity := Vector3.ZERO
	if horizontal_velocity.length() != 0:
		new_velocity = horizontal_velocity.lerp(move_direction * current_speed, ground_friction)
	else:
		new_velocity = move_direction * current_speed
	if gravity != 0:
		var temp =  velocity.y + gravity * delta
		new_velocity.y = temp if temp < terminal_velocity else terminal_velocity
	if _player.is_on_floor():
		new_velocity.y = gravity
	prev_velocity = velocity
	return new_velocity

func grapple_velocity(gravity: float, delta) -> Vector3:
	var new_velocity = velocity
	new_velocity.y += gravity * delta
	return new_velocity

func _throw():
	_player.player_anim_tree.set("parameters/Run/OneShot/active", true)
	emit_signal("throw_fella")


func _on_Friendo_hit_wall(friendo_position):
	grapple_position = friendo_position
	update_state("SwingFromFriendo")
	pass # Replace with function body.
