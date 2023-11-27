extends Node

@onready var state := get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary["Pursue"] = self
	pass # Replace with function body.

var time_til_stopping
var angle
var max_angle = PI/180
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta):
	if state._raycast_middle.is_colliding():
		state._behavior_timer.start(30)
		state.update_state("Idle")
		return
	if abs(state.player.global_position.y - state._blob.global_position.y) > 4:
		state.update_state("Idle")
		return
	
	state.current_speed = lerp(state.current_speed, 14.0, .05)
	var right_collision = state._raycast_right.is_colliding()
	var left_collision = state._raycast_left.is_colliding()
	var adjusted_angle = 0.0
	state._animation_tree["parameters/Idling/blend_amount"] = 1
	if not right_collision and not left_collision:
		state._animation_tree["parameters/Idling/blend_amount"] = 0
		state.current_speed = 0.0
	elif not right_collision:
		adjusted_angle += .5
	elif not left_collision:
		adjusted_angle -= .5
	var player_angle = state._blob.global_position.direction_to(state.player.global_position)
	player_angle = player_angle.rotated(Vector3.UP, adjusted_angle)
	state.move_direction = state.move_direction.slerp(player_angle, .1).normalized()
	state.move_direction.y = 0
	state.move_direction = state.move_direction.normalized()
	state.current_dir = state.move_direction

	state._raycast_middle.target_position = state._raycast_middle.to_local(state.player.global_position + Vector3(0,.5,0))
	var lookdir = atan2(-state.move_direction.x, -state.move_direction.z) + (PI/2)
	state._blob.rotation.y = lookdir
	state.velocity = state.calculate_velocity(delta)


func reset():
	if not state._blob.is_in_group("causes_damage"):
		state._blob.add_to_group("causes_damage")
	state._raycast_middle.set_collision_mask_value(4, false)
	state._animation_tree["parameters/Idling/blend_amount"] = 1
	state._animation_tree["parameters/Running/blend_amount"] = 0
	state.move_direction = state.current_dir
