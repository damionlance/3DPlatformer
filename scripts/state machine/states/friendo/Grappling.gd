extends Node

#private variables
var _state_name = "Grappling"
#onready variables
@onready var _state = get_parent()
@onready var _friendo = get_parent().get_parent()
@onready var _grapple_raycast = $"../../../../GrappleRaycast"

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(_delta):
	# State processing
	if _friendo.is_on_wall() or _friendo.is_on_ceiling() or _grapple_raycast.is_colliding():
		if _grapple_raycast.is_colliding():
			_friendo.position = _grapple_raycast.get_collision_point()
		_state.update_state("StuckToWall")
		_grapple_raycast.enabled = false
		return
	# handle all movement processing
	_grapple_raycast.target_position = _grapple_raycast.to_local(_friendo.global_transform.origin)
	var return_vector = (_state._player.global_transform.origin - _friendo.global_transform.origin).normalized()
	_state.calculate_velocity(return_vector * 500, _delta)
	pass

func reset():
	if _state._player_state.camera_relative_movement:
		_state.move_direction = _state._player_state.camera_relative_movement
	else:
		_state.move_direction = _state._player_state.current_dir
	_state.movement_speed = 40*_state.max_speed
	_grapple_raycast.enabled = true
	_grapple_raycast.target_position = Vector3.ZERO
	pass
