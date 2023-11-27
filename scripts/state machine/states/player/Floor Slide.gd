extends GroundedMovement


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#private variables
var state_name = "FloorSlide"
var _keys

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	pass # Replace with function body.

func update(delta):
	if state.current_speed < .1:
		state.update_state("Running")
		return
	if Input.is_action_pressed("DiveButton"):
		state.update_state("Crouching")
		return
	
	if  state.attempting_jump:
		state.move_direction = -state.move_direction
		state.current_speed = 8
		state.jump_state = state.side_flip
		state.update_state("Jump")
		return
	if not player.is_on_floor():
		state.jump_state = state.jump
		state.update_state("Falling")
		return
	state._air_driftstate = state.not_air_drifting
	state.current_speed *= .91
	
	state.velocity = state.calculate_velocity(0, delta)
	pass

func reset():
	state._reset_animation_parameters()
	state.anim_tree["parameters/conditions/skid"] = true
	state.velocity.y = 0
	state.move_direction = -(state.camera_relative_movement)
	state.current_speed = max_speed
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
