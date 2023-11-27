extends GroundedMovement

class_name Idle

#private variables
var state_name = "Idle"

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	state.update_state(state_name)
	pass # Replace with function body.

func update(delta):
	# Handle all states
	var delta_v = Vector3.ZERO
	player.velocity.y = 0
	if not raycasts.is_on_floor or false:
		state.update_state("Falling")
		return
	if controller.input_strength > .1 or false:
		state.update_state("Running")
		return
	# Handle animation Tree
	
	# Process inputs
	
	# Handle all relevant timers
	player.delta_v = delta_v
	# Process physics
	pass

func reset():
	player.velocity.y = 0
	pass
