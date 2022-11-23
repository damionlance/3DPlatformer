extends Node

class_name Walking


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Running"
var _fall_timer := 0

#onready variables
onready var state = get_parent()
onready var player = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[_state_name] = self
	pass 

func update(delta):
	
	state.is_jumping = false
	if state.attempting_jump:
		state.update_state("Jump")
		return
	
	if !player.is_on_floor():
		_fall_timer += 1
		if _fall_timer > state.CoyoteTime:
			state.update_state("Falling")
			return
	else:
		_fall_timer = 0
	if state.InputDirection == Vector3.ZERO:
		if player.Velocity == Vector3.ZERO:
			state.update_state("Idle")
			return
	
	player.Velocity += state.InputDirection * state.MovementSpeed * state.GroundFriction * delta
	
	pass
