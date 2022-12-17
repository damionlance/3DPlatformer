extends Node
class_name FriendoGrappling

#private variables
var _state_name = "Grappling"
#onready variables
onready var _state = get_parent()
onready var _friendo = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(_delta):
	# State processing
	if _friendo.is_on_wall() or _friendo.is_on_ceiling():
		_state.update_state("StuckToWall")
	# handle all movement processing
	
	_state.calculate_velocity(_delta)
	pass

func reset():
	_state.move_direction = _state._player_state.move_direction
	_state.movement_speed = 4*_state.max_speed
	pass
