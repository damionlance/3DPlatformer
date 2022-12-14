extends GroundedMovement

class_name DiveFloor


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Dive Floor"

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle animation tree
	_player.anim_tree.travel("Floor Slide")
	
	# Process relevant timers
	
	# Handle inputs
	
	# Handle state changes
	if _state.current_speed <= .5:
		_state.update_state("Idle")
		return
	if (_player.is_on_floor()):
		_state.current_speed *= .915
		if _state.attempting_jump:
			_state.update_state("Jump")
		if _state.current_speed < .01:
			_state.current_speed = 0
	else:
		_state.update_state("Falling")
	
	# Process Physics
	_state.velocity = _state.calculate_velocity(0, delta)
	pass

func reset():
	_state.snap_vector = Vector3.DOWN
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
