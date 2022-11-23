extends Node

class_name Falling


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Falling"

#onready variables
onready var state = get_parent()
onready var player = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	if player.is_on_floor():
		player.ClippingVector = Vector3.DOWN
		state.update_state("Idle")
		return
	
	player.ClippingVector = Vector3.ZERO
	state.current_jump += state.fall_gravity * delta
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
