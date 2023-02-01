extends Node
class_name FriendoThrowOut

#private variables
var _state_name = "ThrowOut"
#onready variables
onready var _state = get_parent()
onready var _friendo = get_parent().get_parent()
onready var _grapple_raycast = $"../../../../GrappleRaycast"

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.
var gravity
func update(delta):
	_grapple_raycast.cast_to = _grapple_raycast.to_local(_friendo.global_transform.origin)
	
	if _friendo.is_on_wall() or _friendo.is_on_ceiling() or _grapple_raycast.is_colliding():
		if _grapple_raycast.is_colliding():
			_friendo.translation = _grapple_raycast.get_collision_point()
		_state.update_state("StuckToWall")
		_grapple_raycast.enabled
		return
	
	_state.movement_speed *= .85
	if _state._controller._throw_state:
		gravity.y -= 15
	else:
		gravity.y = 0
	if _state.movement_speed <= .2:
		if not _state._controller._throw_state:
			_state.update_state("Tossing")
			return
		_state.update_state("Idle")
		return
	
	_state.calculate_velocity(gravity, delta)

func reset():
	gravity = Vector3.ZERO
	if _state._player_state.camera_relative_movement:
		_state.move_direction = _state._player_state.camera_relative_movement
	else:
		_state.move_direction = _state._player_state.current_dir
	_state.movement_speed = 40*_state.max_speed
	_grapple_raycast.enabled = true
	_grapple_raycast.cast_to = Vector3.ZERO
	pass
