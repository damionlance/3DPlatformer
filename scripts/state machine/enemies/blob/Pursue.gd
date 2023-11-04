extends Node

@onready var _state := get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary["Pursue"] = self
	pass # Replace with function body.

var time_til_stopping
var angle
var max_angle = PI/180
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta):
	if _state._raycast_middle.is_colliding():
		_state._behavior_timer.start(30)
		_state.update_state("Idle")
		return
	if abs(_state._player.global_position.y - _state._blob.global_position.y) > 4:
		_state.update_state("Idle")
		return
	
	_state.current_speed = lerp(_state.current_speed, 14.0, .05)
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
	var player_angle = _state._blob.global_position.direction_to(_state._player.global_position)
	player_angle = player_angle.rotated(Vector3.UP, adjusted_angle)
	_state.move_direction = _state.move_direction.slerp(player_angle, .1).normalized()
	_state.move_direction.y = 0
	_state.move_direction = _state.move_direction.normalized()
	_state.current_dir = _state.move_direction

	_state._raycast_middle.target_position = _state._raycast_middle.to_local(_state._player.global_position + Vector3(0,.5,0))
	var lookdir = atan2(-_state.move_direction.x, -_state.move_direction.z) + (PI/2)
	_state._blob.rotation.y = lookdir
	_state.velocity = _state.calculate_velocity(delta)


func reset():
	if not _state._blob.is_in_group("causes_damage"):
		_state._blob.add_to_group("causes_damage")
	_state._raycast_middle.set_collision_mask_value(4, false)
	_state._animation_tree["parameters/Idling/blend_amount"] = 1
	_state._animation_tree["parameters/Running/blend_amount"] = 0
	_state.move_direction = _state.current_dir
