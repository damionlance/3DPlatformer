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
	_state._animation_tree["parameters/Idling/blend_amount"] = 1
	_state._animation_tree["parameters/Running/blend_amount"] = 1
	if time_til_stopping == 0:
		_state.update_state("Idle")
		return
	else:
		time_til_stopping -= 1
	
	_state.move_direction = _state.move_direction.rotated(Vector3.UP, angle)
	_state.current_dir = _state.move_direction
	_state.current_speed = lerp(_state.current_speed, 2.0, .05)
	var right_collision = _state._raycast_right.is_colliding()
	var left_collision = _state._raycast_left.is_colliding()
	if not right_collision or not left_collision:
		_state.update_state("Turn Around")
	
	var lookdir = atan2(-_state.move_direction.x, -_state.move_direction.z) + (PI/2)
	_state._blob.rotation.y = lookdir
	_state.velocity = _state.calculate_velocity(delta)


func reset():
	_state.move_direction = _state.current_dir
	angle = randf_range(-max_angle,max_angle)
	time_til_stopping = (randi() % 5) * 60
