extends Node

@onready var _state := get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary["Turn Around"] = self
	pass # Replace with function body.

var goal_direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta):
	_state.move_direction = _state.move_direction.rotated(Vector3.UP, PI/120)
	_state.current_dir = _state.move_direction
	_state.current_speed = lerp(_state.current_speed, .1, .15)
	if (_state.move_direction - goal_direction).length() < .1:
		_state.update_state("Run")
		return

	var lookdir = atan2(-_state.move_direction.x, -_state.move_direction.z) + (PI/2)
	_state._blob.rotation.y = lookdir
	_state.velocity = _state.calculate_velocity(delta)


func reset():
	goal_direction = _state.current_dir * -1
