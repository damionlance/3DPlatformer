extends Node

@onready var _state := get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary["Sniff"] = self
	pass # Replace with function body.

var time_til_stopping
var angle
var max_angle = PI/180
var sniffed = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta):
	if _state.target == null:
		_state.update_state("Idle")
		return
	
	if not "spawn_point" in _state.target:
		var player_angle = _state.target.global_position.direction_to(_state._blob.global_position)
		if player_angle.dot(_state.current_dir) > .5:
			_state.update_state("Idle")
			return
	
	var horizontal_position = Vector3(_state._blob.global_position.x, 0, _state._blob.global_position.z)
	var target_horizontal_position = Vector3(_state.target.global_position.x, 0, _state.target.global_position.z)
	if sniffed:
		if not _state._animation_tree["parameters/Sniffing/active"]:
			_state._behavior_timer.start(30)
			_state.update_state("Idle")
			return
	elif (horizontal_position - target_horizontal_position).length() < 2.5 and not sniffed:
		_state.current_speed = 0.0
		_state.move_direction = Vector3.ZERO
		sniffed = true
		_state._animation_tree["parameters/Sniffing/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	else:
		var right_collision = _state._raycast_right.is_colliding()
		var left_collision = _state._raycast_left.is_colliding()
		var adjusted_angle = 0.0
		_state._animation_tree["parameters/Idling/blend_amount"] = 1
		if not right_collision and not left_collision:
			_state._animation_tree["parameters/Idling/blend_amount"] = 0
			_state.current_speed = 0.0
		elif not right_collision:
			adjusted_angle += .5
		elif not left_collision:
			adjusted_angle -= .5
		var temp = _state.target.global_position
		temp.y = _state._blob.global_position.y
		var angle_to_target = _state._blob.global_position.direction_to(temp)
		angle_to_target = angle_to_target.rotated(Vector3.UP, adjusted_angle)
		_state.move_direction = _state.move_direction.slerp(angle_to_target, .1).normalized()
		_state.current_dir = _state.move_direction
		_state.current_speed = lerp(_state.current_speed, 4.0, .05)
		var lookdir = atan2(-_state.move_direction.x, -_state.move_direction.z) + (PI/2)
		_state._blob.rotation.y = lookdir
	
	_state.velocity = _state.calculate_velocity(delta)


func reset():
	sniffed = false
	_state._animation_tree["parameters/Idling/blend_amount"] = 1
	_state._animation_tree["parameters/Running/blend_amount"] = 1
	_state.move_direction = _state.current_dir
