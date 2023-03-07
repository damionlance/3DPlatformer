extends Node

@onready var _state := get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary["Run"] = self
	pass # Replace with function body.

var time_til_stopping
var angle
var max_angle = PI/180
# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta):
	if time_til_stopping == 0:
		_state.update_state("Idle")
		return
	else:
		time_til_stopping -= 1
	
	var right_collision = _state._raycast_right.is_colliding()
	var left_collision = _state._raycast_left.is_colliding()
	var adjusted_angle = angle
	if not right_collision:
		if not left_collision:
			adjusted_angle += .2
		adjusted_angle += .2
	elif not left_collision:
		adjusted_angle -= .2
	
	_state.move_direction = _state.move_direction.slerp(_state.move_direction.rotated(Vector3.UP, adjusted_angle), .15)
	_state.current_dir = _state.move_direction
	_state.current_speed = lerp(_state.current_speed, 2.0, .05)
	
	var lookdir = atan2(-_state.move_direction.x, -_state.move_direction.z) + (PI/2)
	_state._blob.rotation.y = lookdir
	_state.velocity = _state.calculate_velocity(delta)


func reset():
	_state._raycast_middle.set_collision_mask_value(4, true)
	_state._raycast_middle.target_position = _state._raycast_middle_default
	_state._animation_tree["parameters/Idling/blend_amount"] = 1
	_state._animation_tree["parameters/Running/blend_amount"] = 1
	_state.move_direction = _state.current_dir
	angle = randf_range(-max_angle,max_angle)
	time_til_stopping = (randi() % 5) * 60
