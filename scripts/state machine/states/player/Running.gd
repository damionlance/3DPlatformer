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

var vertical_rotation

var base_rotation = 0
var steep_slope_timer := 0
var steep_slope_buffer := 5
var can_slide := false
var can_slide_timer := 0
var can_slide_buffer := 5
# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	pass 

func update(delta):
	# Handle all states
	var delta_v = Vector3.ZERO
	if not raycasts.is_on_floor:
		state.update_state("Falling")
		return
	if controller.attempting_jump:
		player.jump_state = player.jump
		state.update_state("Jump")
		return
	
	delta_v = grounded_movement_processing(delta)
	player.snap_vector = -raycasts.average_floor_normal
	delta_v.y = 0.0
	player.delta_v = delta_v
	pass

func reset():
	player.velocity.y = 0
	pass
