extends Node
class_name FriendoThrowing

#private variables
var _state_name = "Throwing"
#onready variables
@onready var _state = get_parent()
@onready var _friendo = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(_delta):
	# State processing
	if _friendo.toss_friendo:
		_state.update_state("ThrowOut")
		return
	
	# handle all movement processing
	_friendo.position = _state._hand_node.global_transform.origin
	pass

func reset():
	
	pass
