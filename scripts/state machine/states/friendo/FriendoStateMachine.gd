extends Node

#public variables
var state_dictionary : Dictionary

#Friendo Physics Variables
var velocity :=  Vector3.ZERO
var move_direction := Vector3.ZERO
var movement_speed := 0.0
var max_speed := 5.0

var grapple_position = Vector3.ZERO

var _currentstate

#onready variables
@onready var playerstate = get_parent().get_parent().get_parent().get_node("StateMachine")
@onready var player = get_parent().get_parent().get_parent()
@onready var _friendo = get_parent()
@onready var _camera = find_child("CameraPivot")
@onready var controller = player.find_child("Controller")

@onready var _homing_node = $"../../../FriendoHomingNode"

# Called when the node enters the scene tree for the first time.
func _ready():
	state_dictionary.is_empty()
	update_state("Idle")
	pass # Replace with function body.

func _process(delta):
	_currentstate.update(delta)

func update_state( newstate ):
	_currentstate = state_dictionary[newstate]
	_currentstate.reset()

func calculate_velocity(gravity, delta):
	velocity = (move_direction * movement_speed) + gravity * delta
	_friendo.velocity = velocity
