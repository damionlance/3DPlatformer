extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var state_name = "Idle"
#onready variables
@onready var state = get_parent()
@onready var _friendo = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	pass # Replace with function body.

func update(_delta):
	# State processing
	if _friendo.throwing:
		state.update_state("Throwing")
		return
	
	# handle all movement processing
	if _friendo.position.distance_to(state._homing_node.global_transform.origin) > .5:
		var friendoPos = _friendo.global_transform.origin
		var goalPos = state._homing_node.global_transform.origin
		state.move_direction = goalPos - friendoPos
		state.movement_speed = state.max_speed
	else:
		state.move_direction = Vector3.ZERO
		state.movement_speed = 0
	
	
	state.calculate_velocity(Vector3.ZERO, _delta)
	pass

func reset():
	_friendo.throwing = false
	pass
