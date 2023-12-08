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
	delta_v = Vector3.ZERO
	if not raycasts.is_on_floor:
		state.update_state("Falling")
		return
	if controller.attempting_jump:
		player.jump_state = player.jump
		state.update_state("Jump")
		return
	if controller.input_strength > .1:
		state.update_state("Running")
		return
	# Handle animation Tree
	# Process inputs
	
	delta_v = grounded_movement_processing(delta)
	
	# Handle all relevant timers
	player.delta_v = delta_v
	player.snap_vector = -raycasts.average_floor_normal
	# Process physics
	pass

func reset(_delta):
	pass
