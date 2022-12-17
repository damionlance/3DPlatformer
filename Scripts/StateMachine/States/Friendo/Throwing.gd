extends Node
class_name FriendoThrowing

#private variables
var _state_name = "Throwing"
#onready variables
onready var _state = get_parent()
onready var _friendo = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(_delta):
	# State processing
	if _friendo.toss_friendo:
		if _state._controller._throw_state != 0:
			_state.update_state("Grappling")
		else:
			_state.update_state("Tossing")
		return
	
	# handle all movement processing
	_friendo.translation = _state._hand_node.global_transform.origin
	pass

func reset():
	pass
