extends Node
class_name FriendoTossing

#private variables
var _state_name = "Tossing"
#onready variables
onready var _state = get_parent()
onready var _friendo = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(_delta):
	# State processing
	print("Tossed!")
	_state.update_state("Idle")
	# handle all movement processing
	
	_state.calculate_velocity(_delta)
	pass

func reset():
	var direction = _state._player.move_direction if _state._player.move_direction else _state._player.current_dir
	print(direction)
	_state.move_direction = direction
	_state.movement_speed = 2*_state.max_speed
	pass
