extends Node

#public variables
var state_dictionary : Dictionary

#Friendo Physics Variables
var velocity :=  Vector3.ZERO
var move_direction := Vector3.ZERO
var movement_speed := 0.0
var max_speed := 5.0

var grapple_position = Vector3.ZERO

var _current_state

#onready variables
onready var _player_state = get_parent().get_parent().get_parent().get_node("StateMachine")
onready var _player = get_parent().get_parent().get_parent()
onready var _friendo = get_parent()
onready var _camera = find_node("CameraPivot")
onready var _controller = find_node("Controller")

onready var _homing_node = $"../../../FriendoHomingNode"
onready var _hand_node = $"../../../lilfella/Armature/Skeleton/RightHand"

# Called when the node enters the scene tree for the first time.
func _ready():
	state_dictionary.empty()
	update_state("Idle")
	pass # Replace with function body.

func _process(delta):
	_current_state.update(delta)

func update_state( new_state ):
	_current_state = state_dictionary[new_state]
	_current_state.reset()

func calculate_velocity(gravity, delta):
	velocity = (move_direction * movement_speed) + gravity * delta
	_friendo.velocity = velocity
