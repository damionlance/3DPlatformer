extends Node

#private variables
var state_name = "Throwing"
#onready variables
@onready var state = get_parent()
@onready var _friendo = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	pass # Replace with function body.

func update(_delta):
	# State processing
	if _friendo.toss_friendo:
		state.update_state("ThrowOut")
		return
	
	# handle all movement processing
	_friendo.position = state._hand_node.global_transform.origin
	pass

func reset():
	
	pass
