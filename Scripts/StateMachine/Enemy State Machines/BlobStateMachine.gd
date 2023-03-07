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

#onready variables
@onready var _blob = get_parent()
@onready var _raycast_left = _blob.get_node("Left Raycast")
@onready var _raycast_right = _blob.get_node("Right Raycast")
@onready var _raycast_middle = _blob.get_node("Front Raycast")
@onready var _player = _blob.owner.find_child("Player")
@onready var _animation_tree = $"../AnimationTree"

# Called when the node enters the scene tree for the first time.
func _ready():
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
	if see_player():
		update_state("Pursue")
		return

func see_player() -> bool:
	var player_angle = _blob.global_position.direction_to(_player.global_position)
	if player_angle.dot(current_dir) > .5:
		return true
	return false
