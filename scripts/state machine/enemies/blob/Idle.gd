extends Node

@onready var state := get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary["Idle"] = self
	pass # Replace with function body.

var time_til_running

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta):
	if time_til_running == 0:
		state.update_state("Run")
	else:
		time_til_running -= 1
	state.current_speed = lerp(state.current_speed, 0.0, .05)
	state.velocity = state.calculate_velocity(delta)

func reset():
	if state._blob.is_in_group("causes_damage"):
		state._blob.remove_from_group("causes_damage")
	state.move_direction = Vector3.ZERO
	state._raycast_middle.set_collision_mask_value(4, true)
	state._raycast_middle.target_position = state._raycast_middle_default
	state._animation_tree["parameters/Idling/blend_amount"] = 0
	time_til_running = (randi() % 8) * 60
