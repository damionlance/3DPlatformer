extends GroundedMovement

class_name Walking


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Running"
var _fall_timer := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass 

func update(delta):
	# Handle all states
	if _state._controller.spin_entered:
		_state.update_state("Floor Spin")
	if _state._controller.pivot_entered and _state.current_speed > max_speed*.5:
		_state.update_state("FloorSlide")
		return
	if _state.attempting_dive:
		_state.update_state("Dive")
		return
	if _state.attempting_jump:
		_state.update_state("Jump")
		return
	if not _player.is_on_floor():
		_fall_timer += 1
		if _fall_timer > _state.coyote_time:
			_state.update_state("Falling")
			return
	else:
		_fall_timer = 0
	if _state.current_speed == 0 and not _state._controller.movement_direction:
		_state.update_state("Idle")
		return
	# Handle Animation Tree
	_player.anim_tree.travel("Run")
	#_player.particles.emitting = true
	
	# Process all inputs
	grounded_movement_processing()
	if _state.move_direction:
		# This insanely long line calculates the vector of the player's direction
		# from the camera's perspective and interpolates to that value by some rotation speed
		var target_direction = _player.transform.looking_at(_player.global_transform.origin + _state.move_direction, Vector3.UP)
		_player.transform = _player.transform.interpolate_with(target_direction, floor_rotation_speed)
	
	# Process all relevant timers
	
	#Process physics
	_state.velocity = _state.calculate_velocity(0, delta)
	
	pass

func reset():
	_state._air_drift_state = _state.not_air_drifting
	_state.snap_vector = Vector3.DOWN
	_state.velocity.y = 0
	pass
