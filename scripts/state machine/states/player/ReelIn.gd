extends AerialMovement


#private variables
var state_name = "ReelIn"

#onready variables
@onready var _grapple_raycast = $"../../../GrappleRaycast"
@onready var _friendo = $"../../../FriendoHomingNode/Friendo"

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	pass # Replace with function body.

var altered

func update(delta):
	# Handle all state logic
	if state.attempting_dive:
		player.grappling = false
		state.jump_state = state.dive
		state.update_state("Jump")
		return
	if state.attempting_jump:
		player.grappling = false
		state.jump_state = state.jump
		state.update_state("Jump")
		return
	# Handle animation tree
	
	# Process movements
	var diff = altered - player.global_transform.origin
	if diff.length() < 1:
		player.grappling = false
		state.jump_state = state.jump
		state.update_state("Falling")
		return
	else:
		var direction = altered
		direction.y = player.transform.origin.y
		player.transform = player.transform.looking_at(direction, Vector3.UP)
	# Update all relevant counters
	
	# Process physics
	state.move_direction = diff.normalized()
	state.current_speed += 1.5 if state.current_speed < constants.max_reel_in else 0.0
	state.velocity = state.calculate_velocity(0, delta)
	
	pass

func reset():
	state._reset_animation_parameters()
	player.grappling = false
	altered = _friendo.global_position
	altered.y -= 1.25
	constants.shorthop_timer = 0
	state.snap_vector = Vector3.ZERO
	pass
