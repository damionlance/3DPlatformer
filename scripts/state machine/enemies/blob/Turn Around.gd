extends Node

@onready var state := get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary["Turn Around"] = self
	pass # Replace with function body.

var goal_direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta):
	
	state._animation_tree["parameters/Idling/blend_amount"] = 1
	state._animation_tree["parameters/Running/blend_amount"] = 1
	
	state.move_direction = state.move_direction.rotated(Vector3.UP, PI/120)
	state.current_dir = state.move_direction
	state.current_speed = lerp(state.current_speed, .1, .15)
	if (state.move_direction - goal_direction).length() < .1:
		state.update_state("Run")
		return

	var lookdir = atan2(-state.move_direction.x, -state.move_direction.z) + (PI/2)
	state._blob.rotation.y = lookdir
	state.velocity = state.calculate_velocity(delta)


func reset():
	goal_direction = state.current_dir * -1
