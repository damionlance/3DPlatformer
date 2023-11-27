extends Node

#private variables
var state_name = "Grappling"
#onready variables
@onready var state = get_parent()
@onready var _friendo = get_parent().get_parent()
@onready var _grapple_raycast = $"../../../../GrappleRaycast"

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	pass # Replace with function body.

func update(_delta):
	# State processing
	if _friendo.is_on_wall() or _friendo.is_on_ceiling() or _grapple_raycast.is_colliding():
		if _grapple_raycast.is_colliding():
			_friendo.position = _grapple_raycast.get_collision_point()
		state.update_state("StuckToWall")
		_grapple_raycast.enabled = false
		return
	# handle all movement processing
	_grapple_raycast.target_position = _grapple_raycast.to_local(_friendo.global_transform.origin)
	var return_vector = (state.player.global_transform.origin - _friendo.global_transform.origin).normalized()
	state.calculate_velocity(return_vector * 500, _delta)
	pass

func reset():
	if state.playerstate.camera_relative_movement:
		state.move_direction = state.playerstate.camera_relative_movement
	else:
		state.move_direction = state.playerstate.current_dir
	state.movement_speed = 40*state.max_speed
	_grapple_raycast.enabled = true
	_grapple_raycast.target_position = Vector3.ZERO
	pass
