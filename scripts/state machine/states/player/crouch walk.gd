extends GroundedMovement


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String
var blend_parameter = "parameters/GroundedMovement/Crouching/blend_position"

#private variables
var state_name = "Crouching"
var _fall_timer := 0

var vertical_rotation

var base_rotation = 0
var can_slide := false
var can_slide_timer := 0
var can_slide_buffer := 5
# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	pass 

func update(delta):
	var delta_v = Vector3.ZERO
	# Handle all states
	if not Input.is_action_pressed("DiveButton"):
		state.update_state("Running")
		return
	if controller.attempting_jump:
		if controller.input_strength > .1:
			player.jump_state = player.long_jump
		else:
			player.jump_state = player.side_flip
		state.update_state("Jump")
		return
	if not raycasts.is_on_floor:
		player.jump_state = player.jump
		state.update_state("Falling")
		return
	else:
		_fall_timer = 0
	# Handle Animation Tree
	
	# Process all inputs
	delta_v = controller.camera_relative_movement * controller.input_strength * crouching_acceleration
	delta_v = grounded_movement_processing(delta, delta_v)
	animation_tree[blend_parameter] = lerpf(animation_tree[blend_parameter], player.velocity.length()/(player.max_horizontal_velocity * delta), 0.15)
	
	#Process physics
	player.delta_v = delta_v
	pass

func reset(_delta):
	player.max_horizontal_velocity = 4
	player.look_at_velocity = true
