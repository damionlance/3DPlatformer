extends Node

#public variables
var state_dictionary : Dictionary

#Player Physics Variables
var velocity :=  Vector3.ZERO
var snap_vector := Vector3.DOWN

var grapple_position = Vector3.ZERO

# Special inputs tracking
var previous_angle := [0.0, 0.0]
var previous_direction := Vector2.ZERO
var spin_jump_executed := false
var _wall_jump_buffer := 5
var _wall_jump_timer := 0
export var _shorthop_buffer := 0
var _shorthop_timer := 7
var pivot_buffer = []
var pivot_buffer_size := 10

# ALL SPIN JUMP STATE HANDLING
var spin_jump_angle := 0.0
var spin_jump_start := Vector2.ZERO
var spin_jump_sign := int(0)

var just_landed = false

var _consecutive_jump_timer := 0
var _consecutive_jump_buffer := 5

var _jump_buffer := 5
var _jump_timer := 5
var _dive_timer := 5

export var coyote_time := 10


var _current_state

var _air_drift_state
enum {
	not_air_drifting,
	air_drifting
}

var attempting_jump := false
var allow_jump := false
var attempting_dive := false
var allow_dive := false
var spin_allowed := false
var spin_timer := 0
var spin_buffer := 30
var is_on_floor := false
var attempting_throw := false

var camera_relative_movement := Vector3.ZERO
var move_direction := Vector3.ZERO
var character_model_direction := Vector2.ZERO
var current_dir := Vector2(0,1)
var desired_speed = 0.0
var current_speed = 0.0

# Used for calculating camera relative inputs.
var forwards := Vector3.ZERO
var right := Vector3.ZERO

#onready variables
onready var _player = get_parent()
onready var _camera = $"../CameraPivot"
onready var _raycast_left = _player.get_node("WallRayLeft")
onready var _raycast_right = _player.get_node("WallRayRight")
onready var _controller = $"../Controller"

#signals
signal throw_fella

# Called when the node enters the scene tree for the first time.
func _ready():
	update_state("Falling")
	pivot_buffer.resize(pivot_buffer_size)
	state_dictionary.empty()
	pass # Replace with function body.

func _process(delta):
	print(_current_state._state_name)
	
	input_handling()
	_current_state.update(delta)
	_player.update_physics_data(velocity, snap_vector)
	velocity = _player.velocity
	
	update_shadow()

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
	elif _controller._dive_state == _controller.dive_held and _jump_buffer < _jump_timer:
		attempting_dive = true
		_jump_buffer += 1
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
	var new_velocity = move_direction * current_speed
	new_velocity.y += velocity.y + gravity * delta
	return new_velocity
	
func update_shadow():
	# update shadow
	var player_shadow = _player.get_node("PlayerShadow")
	var player_body = _player.get_node("lilfella")
	var space_state = _player.get_world().direct_space_state
	var result = space_state.intersect_ray(Vector3(0, _player.translation.y, 0), _player.translation + Vector3(0, -20, 0))
	if result:
		if "worldspawn" in result.collider.name:
			var distance_from_ground = result.position - _player.translation
			player_shadow.update_shadow(_player.translation, distance_from_ground.y, _player.rotation)

func _throw():
	_player.player_anim_tree["parameters/Run/OneShot/active"] = true
	emit_signal("throw_fella")


func _on_Friendo_hit_wall(friendo_position):
	grapple_position = friendo_position
	update_state("SwingFromFriendo")
	pass # Replace with function body.
