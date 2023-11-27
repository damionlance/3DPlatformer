extends Node

@onready var state := get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary["Run"] = self
	pass # Replace with function body.

var time_til_stopping
var angle
var max_angle = PI/60
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta):
	if time_til_stopping == 0:
		state.update_state("Idle")
		return
	else:
		time_til_stopping -= 1
	
	var right_collision = state._raycast_right.is_colliding()
	var left_collision = state._raycast_left.is_colliding()
	var adjusted_angle = angle
	if not right_collision:
		if not left_collision:
			adjusted_angle += .2
		adjusted_angle += .2
	elif not left_collision:
		adjusted_angle -= .2
	
	state.move_direction = state.move_direction.slerp(state.move_direction.rotated(Vector3.UP, adjusted_angle), .15)
	state.current_dir = state.move_direction
	state.current_speed = lerp(state.current_speed, 2.0, .05)
	
	var lookdir = atan2(-state.move_direction.x, -state.move_direction.z) + (PI/2)
	state._blob.rotation.y = lookdir
	state.velocity = state.calculate_velocity(delta)


func reset():
	state._raycast_middle.set_collision_mask_value(4, true)
	state._raycast_middle.target_position = state._raycast_middle_default
	state._animation_tree["parameters/Idling/blend_amount"] = 1
	state._animation_tree["parameters/Running/blend_amount"] = 1
	state.move_direction = state.current_dir
	angle = randf_range(-max_angle,max_angle)
	time_til_stopping = (randi() % 5) * 60
