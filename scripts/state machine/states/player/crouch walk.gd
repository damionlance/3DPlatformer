extends GroundedMovement


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

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
	# Handle all states
	if not Input.is_action_pressed("DiveButton"):
		state.update_state("Running")
		return
	if state.attempting_jump and not state.can_interact:
		
		if state.current_speed < 5:
			for body in get_tree().get_nodes_in_group("holdable"):
				if (body.global_position - player.global_position).length() < 2.5:
					if previous_move_direction.dot((body.global_position - player.global_position)) > .5:
						state._holdable_object_node.hold_object(body)
						return
		
		if state.just_landed and state.current_jump < 3:
			state.current_jump += 1
		else:
			state.current_jump = 1
		if state._controller.input_strength > .1:
			state.jump_state = state.long_jump
		else:
			state.jump_state = state.side_flip
		state.update_state("Jump")
		return
	if not player.is_on_floor():
		state.jump_state = state.jump
		state.update_state("Falling")
		state.anim_tree["parameters/conditions/fall"] = true
		return
	else:
		_fall_timer = 0
	# Handle Animation Tree
	if state.attempting_throw:
		state._throw()
	
	state.anim_tree["parameters/crouching/crouch blend/blend_amount"] = state.current_speed/crouch_walk
	# Process all inputs
	
	previous_speed = state.current_speed
	state.current_dir = state.move_direction
	
	# Process all relevant timers
	if state.current_speed > max_speed * .9:
		can_slide = true
		can_slide_timer = 0
	elif can_slide:
		can_slide_timer += 1
		if can_slide_timer == can_slide_buffer:
			can_slide_timer = 0
			can_slide = false

	#Process physics
	state.velocity = state.calculate_velocity(0, delta)
	pass

func reset():
	state._reset_animation_parameters()
	state.anim_tree["parameters/conditions/crouching"] = true
	get_parent().dashing = false
	state._air_driftstate = state.not_air_drifting
	var collision = player.get_last_slide_collision()
	if collision:
		state.snap_vector = Vector3.DOWN
	else:
		state.snap_vector = Vector3.ZERO
	state.velocity.y = 0
	can_slide = false
	can_slide_timer = 0
	player.rotation.z = 0
	pass
