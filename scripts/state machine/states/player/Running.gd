extends GroundedMovement


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var state_name = "Running"
var _fall_timer := 0
var blend_parameter = "parameters/GroundedMovement/Running/blend_position"

var vertical_rotation

var base_rotation = 0
var steep_slope_timer := 0
var steep_slope_buffer := 5
var can_slide := false
var can_slide_timer := 0
var can_slide_buffer := 5

var consecutive_jump_number := 0

var consecutive_jump_buffer := 5
var consecutive_jump_timer := 0
# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	pass 

func update(delta):
	if consecutive_jump_number == 3 or consecutive_jump_timer == consecutive_jump_buffer:
		consecutive_jump_timer = 0
		consecutive_jump_number = 0
	if consecutive_jump_number != 0:
		consecutive_jump_timer += 1
		# Handle all states
	var delta_v = Vector3.ZERO
	if controller.attempting_jump:
		consecutive_jump_number += 1
		player.jump_state = consecutive_jump_number
		state.update_state("Jump")
		return
	if not raycasts.is_on_floor:
		state.update_state("Falling")
		return
	
	delta_v = grounded_movement_processing(delta)
	player.snap_vector = -raycasts.average_floor_normal * 0.25
	delta_v.y = 0.0
	player.delta_v = delta_v
	animation_tree[blend_parameter] = lerpf(animation_tree[blend_parameter], controller.input_strength/1.0, 0.15)
	pass

func reset(_delta):
	pass
