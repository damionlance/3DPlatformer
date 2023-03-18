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
var gravity : int = ProjectSettings.get_setting("physics/2d/default_gravity")
var _current_state = null

var is_on_floor := false

var move_direction := Vector3.ZERO
var current_dir := Vector3.ZERO
var desired_speed = 0.0
var current_speed = 0.0

# Used for calculating camera relative inputs.
var forwards := Vector3.ZERO
var right := Vector3.ZERO

var ground_friction := 1.0

var target
var home = null

#onready variables
@onready var _blob = get_parent()
@onready var _raycast_left = _blob.get_node("Left Raycast")
@onready var _raycast_right = _blob.get_node("Right Raycast")
@onready var _raycast_middle = _blob.get_node("Front Raycast")
@onready var _player = _blob.owner.find_child("Player")
@onready var _animation_tree = $"../AnimationTree"
@onready var _behavior_timer = $"../BehaviorTimer"

var _raycast_middle_default

# Called when the node enters the scene tree for the first time.
func _ready():
	_raycast_middle_default = _raycast_middle.target_position
	if "spawn_point" in _blob.get_parent():
		home = _blob.get_parent()
	current_dir = _raycast_middle.target_position.normalized()
	state_dictionary.is_empty()
	pass # Replace with function body.

func _process(delta):
	if _current_state == null:
		update_state("Idle")
	_current_state.update(delta)
	if _current_state.name == "Idle" or _current_state.name == "Run":
		process_interests()


func update_state( new_state ):
	_current_state = state_dictionary[new_state]
	_current_state.reset()

func calculate_velocity(delta) -> Vector3:
	velocity = move_direction * current_speed
	velocity.y -= gravity * delta
	return velocity

func process_interests():
	if seek_pleasant_smells():
		update_state("Pursue")
		return
	if seek_home():
		update_state("Sniff")
		return
	if _behavior_timer.time_left != 0:
		return
	if see_butt():
		update_state("Sniff")
		return

func seek_home():
	if home != null:
		var horizontal_position = Vector3(_blob.global_position.x, 0, _blob.global_position.z)
		var target_horizontal_position = Vector3(home.global_position.x, 0, home.global_position.z)
		if (horizontal_position - target_horizontal_position).length() < 20:
			return false
		_raycast_middle.set_collision_mask_value(4, false)
		_raycast_middle.target_position = _raycast_middle.to_local(home.global_position)
		_raycast_middle.force_raycast_update()
		_raycast_middle.target_position = _raycast_middle_default
		_raycast_middle.set_collision_mask_value(4, true)
		if not _raycast_middle.is_colliding():
			target = home
			return true
	return false

func see_butt():
	var body = _raycast_middle.get_collider()
	if body == null:
		return false
	if body.is_in_group("has_butt"):
		target = body
		return true
	return false

func seek_pleasant_smells() -> bool:
	for body in get_tree().get_nodes_in_group("pleasant_smelling"):
		if (body.global_position - _blob.global_position).length() > 20:
			continue
		var player_angle = _blob.global_position.direction_to(body.global_position)
		if player_angle.dot(current_dir) > .5:
			_raycast_middle.target_position = _raycast_middle.to_local(body.global_position + Vector3(0,.5,0))
			_raycast_middle.force_raycast_update()
			_raycast_middle.target_position = _raycast_middle_default
			if not _raycast_middle.is_colliding():
				return true
	return false
