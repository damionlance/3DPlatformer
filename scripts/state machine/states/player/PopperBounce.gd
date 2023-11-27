extends AerialMovement


#private variables
var state_name = "PopperBounce"

#onready variables

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle all state logic
	if state.attempting_dive:
		state.update_state("Dive")
		return
	
	match wall_collision_check():
		wall_collision.wallSlide:
			state.update_state("WallSlide")
			return
		wall_collision.ledgeGrab:
			state.update_state("LedgeGrab")
			return
	
	if state.velocity.y < 0:
		state.update_state("Falling")
		return
	# Handle animation tree
	
	# Process movements
	standard_aerial_drift()
	
	# Update all relevant counters
	
	# Process physics
	state.velocity = state.calculate_velocity(constants._side_jump_gravity, delta)
	pass

func reset():
	state._reset_animation_parameters()
	state.anim_tree["parameters/conditions/jump"] = true
	
	constants.entering_jump_angle = Vector3(player.popperAngle.x, 0, player.popperAngle.z)
	state.move_direction = Vector3(player.popperAngle.x, 0, player.popperAngle.z)
	state.current_speed = constants.wall_jump_speed * constants.entering_jump_angle.length()
	state.snap_vector = Vector3.ZERO
	state.velocity.y = constants._side_jump_strength
	player.transform = player.transform.looking_at(player.global_transform.origin + state.move_direction, Vector3.UP)
	pass
