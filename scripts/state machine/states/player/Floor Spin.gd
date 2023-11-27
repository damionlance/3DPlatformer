extends GroundedMovement

#private variables
var state_name = "Floor Spin"

var _spinning_timer := 90
var _spinning_buffer := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle All State Logic
	if not player.is_on_floor():
		state.jump_state = state.spin_jump
		state.update_state("Falling")
		return
	if state.attempting_jump:
		state.jump_state = state.spin_jump
		state.update_state("Jump")
		return
	if state.controller.spin_entered:
		_spinning_buffer = 0
	_spinning_buffer += 1
	if _spinning_buffer == _spinning_timer:
		state.anim_tree["parameters/conditions/running"] = true
		state.anim_tree["parameters/conditions/spinning"] = false
		state.update_state("Running")
	
	# Handle Animation Tree
	
	# Handle movements
	grounded_movement_processing()
	
	# Update relevant timers
	
	
	#Process Physics
	state.velocity = state.calculate_velocity(-1, delta)
	pass

func reset():
	state._reset_animation_parameters()
	state.anim_tree["parameters/conditions/spinning"] = true
	player.rotation.z = 0
	state.snap_vector = Vector3.DOWN
	_spinning_buffer = 0
	pass
