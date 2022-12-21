extends Node
class_name FriendoGrappling

#private variables
var _state_name = "Grappling"
#onready variables
onready var _state = get_parent()
onready var _friendo = get_parent().get_parent()
onready var _grapple_raycast = $"../../../../GrappleRaycast"

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(_delta):
	# State processing
	if _friendo.is_on_wall() or _friendo.is_on_ceiling() or _grapple_raycast.is_colliding():
		if _grapple_raycast.is_colliding():
			_friendo.translation = _grapple_raycast.get_collision_point()
		_state.update_state("StuckToWall")
		_grapple_raycast.enabled = false
		_grapple_raycast.cast_to = Vector3.ZERO
		return
	# handle all movement processing
	_grapple_raycast.cast_to = _grapple_raycast.to_local(_friendo.global_transform.origin)
	
	_state.calculate_velocity(_delta)
	pass

func reset():
	_state.move_direction = _state._player_state.camera_relative_movement
	_state.movement_speed = 40*_state.max_speed
	_grapple_raycast.enabled = true
	pass
