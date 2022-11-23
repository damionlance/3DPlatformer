extends Node

class_name Jump


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Jump"

#onready variables
onready var state = get_parent()
onready var player = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	print(_state_name)
	if !state.attempting_jump:
		state.current_jump *= .6
		state.update_state("Falling")
		return
	
	if !state.is_jumping:
		player.ClippingVector = Vector3.ZERO
		state.current_jump = state.jump_velocity
		state.is_jumping = true
	
	state.current_jump += state.jump_gravity * delta
		
	if player.Velocity.y < 0:
		
		state.update_state("Falling")
		return
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
