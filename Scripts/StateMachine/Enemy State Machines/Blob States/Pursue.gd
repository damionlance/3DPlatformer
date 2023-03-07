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
	_state._animation_tree["parameters/Idling/blend_amount"] = 1
	_state._animation_tree["parameters/Running/blend_amount"] = 0
	var player_angle = _state._blob.global_position.direction_to(_state._player.global_position)
	_state.move_direction = _state.move_direction.slerp(player_angle, .1).normalized()
	_state.current_dir = _state.move_direction
	_state.current_speed = lerp(_state.current_speed, 4.0, .05)
	

	var lookdir = atan2(-_state.move_direction.x, -_state.move_direction.z) + (PI/2)
	_state._blob.rotation.y = lookdir
	_state.velocity = _state.calculate_velocity(delta)


func reset():
	_state.move_direction = _state.current_dir
