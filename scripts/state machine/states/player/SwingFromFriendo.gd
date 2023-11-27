extends AerialMovement

var state_name = "SwingFromFriendo"

@onready var grapple = $"../../../GrappleRaycast"

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	
	pass # Replace with function body.

func update(_delta):
	if controller.throw_state == 0:
		player.grappling = false
		state.jump_state = state.jump
		state.update_state("Falling")
		return
	if state.attempting_dive:
		state.update_state("ReelIn")
		return
	if state.attempting_jump:
		player.grappling = false
		state.jump_state = state.jump
		state.update_state("Jump")
		return
	state.current_speed = state.velocity.length()
	state.move_direction = state.velocity.normalized()
	pass

func reset():
	state._reset_animation_parameters()
	player.grappling = true
	player.grapple_slider.linear_velocity = player.velocity
	state.velocity.y = 0
	pass
