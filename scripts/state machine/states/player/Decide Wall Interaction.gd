extends AerialMovement

#private variables
var state_name = "Decide Wall Interaction"

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self

func reset(_delta):
	var entering_jump_velocity = player.velocity
	var wall_normal = raycasts.closest_wall_normal
	
	var wall_velocity_dot_product = entering_jump_velocity.dot(wall_normal)
	if wall_velocity_dot_product > 0: # If you're moving away from the wall, you shouldn't be here.
		state.update_state(state.previous_state.state_name)
		return
	if wall_velocity_dot_product < -0.75: # Arbitrarily saying what direction counts as a normal wall slide
		state.update_state("Wall Slide")
	else:
		state.update_state("Wall Run")
	return
