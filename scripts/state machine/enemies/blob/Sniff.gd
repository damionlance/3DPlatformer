extends Node

@onready var state := get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary["Sniff"] = self
	pass # Replace with function body.

var time_til_stopping
var angle
var max_angle = PI/180
var sniffed = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta):
	if state.target == null:
		state.update_state("Idle")
		return
	
	if not "spawn_point" in state.target:
		var player_angle = state.target.global_position.direction_to(state._blob.global_position)
		if player_angle.dot(state.current_dir) > .5:
			state.update_state("Idle")
			return
	
	var horizontal_position = Vector3(state._blob.global_position.x, 0, state._blob.global_position.z)
	var target_horizontal_position = Vector3(state.target.global_position.x, 0, state.target.global_position.z)
	if sniffed:
		if not state._animation_tree["parameters/Sniffing/active"]:
			state._behavior_timer.start(30)
			state.update_state("Idle")
			return
	elif (horizontal_position - target_horizontal_position).length() < 2.5 and not sniffed:
		state.current_speed = 0.0
		state.move_direction = Vector3.ZERO
		sniffed = true
		state._animation_tree["parameters/Sniffing/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	else:
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
		var temp = state.target.global_position
		temp.y = state._blob.global_position.y
		var angle_to_target = state._blob.global_position.direction_to(temp)
		angle_to_target = angle_to_target.rotated(Vector3.UP, adjusted_angle)
		state.move_direction = state.move_direction.slerp(angle_to_target, .1).normalized()
		state.current_dir = state.move_direction
		state.current_speed = lerp(state.current_speed, 4.0, .05)
		var lookdir = atan2(-state.move_direction.x, -state.move_direction.z) + (PI/2)
		state._blob.rotation.y = lookdir
	
	state.velocity = state.calculate_velocity(delta)


func reset():
	sniffed = false
	state._animation_tree["parameters/Idling/blend_amount"] = 1
	state._animation_tree["parameters/Running/blend_amount"] = 1
	state.move_direction = state.current_dir
