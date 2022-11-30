extends Node

class_name Jump


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Jump"
var shorthop_timer := 0

#onready variables
onready var _state = get_parent()
onready var _player = get_parent().get_parent()

var entering_angle : Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	_player.player_anim.play("Jump")
	
	var forwards = _state._camera.global_transform.basis.z
	forwards.y = 0
	forwards = forwards.normalized()
	forwards *= _state.input_direction.z
	var right = _state._camera.global_transform.basis.x * _state.input_direction.x
	
	shorthop_timer += 1
	
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
	
	_state.velocity = _state.calculate_velocity(_state._jump_gravity, delta)
	
	if _state.wall_jump_collision_check() and _state._allow_wall_jump:
		_state.update_state("WallSlide")
		return
	if not _state.attempting_jump and shorthop_timer == _state._shorthop_buffer:
		_state.velocity.y *= .6
		_state.update_state("Falling")
		return
	if _state.velocity.y < 0:
		_state.update_state("Falling")
		return
	
	pass

func reset():
	shorthop_timer = 0
	_state.entering_jump_angle = _state.input_direction
	_state.snap_vector = Vector3.ZERO
	_state.velocity.y = _state._jump_strength
	_state._jump_state = _state.jump_held
	_player.transform = _player.transform.looking_at(_player.global_transform.origin + _state.move_direction, Vector3.UP)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
