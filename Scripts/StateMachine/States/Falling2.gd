extends Node

class_name Falling2


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Falling2"

#onready variables
onready var _state = get_parent()
onready var _player = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	_player.player_anim.play("Fall")
	if _player.is_on_floor():
		_state.snap_vector = Vector3.DOWN
		_state.update_state("Idle")
		return
	if _player.is_on_wall() and _state._allow_wall_jump:
		_state.update_state("WallSlide")
		return
	var forwards = _state._camera.global_transform.basis.z
	forwards.y = 0
	forwards = forwards.normalized()
	forwards *= _state.input_direction.z
	var right = _state._camera.global_transform.basis.x * _state.input_direction.x
	
	if _state.move_direction.length() > 1:
		_state.move_direction = _state.move_direction.normalized()
	_state.move_direction.y = 0
	
	_state.snap_vector = Vector3.ZERO
	if abs(_state.input_direction.angle_to(_state.entering_jump_angle)) > (3 * PI)/4:
		# Drift Backwards logic
		_state.current_speed += _state.air_acceleration
		_state._air_drift_state = _state.not_air_drifting
	elif abs(_state.input_direction.angle_to(_state.entering_jump_angle)) > PI/3:
		# Drift Sideways logic
		if (_state._air_drift_state == _state.not_air_drifting):
			_state._air_drift_state = _state.air_drifting
		
		
	elif not _state.input_direction:
		_state._air_drift_state = _state.not_air_drifting
		_state.current_speed *= _state.air_friction
	if _state.current_speed > _state.max_speed:
		_state.current_speed = _state.max_speed
	
	#_state.move_direction = forwards + right
	_state.velocity = _state.calculate_velocity(_state._fall2_gravity, delta)
	
	pass

func reset():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
