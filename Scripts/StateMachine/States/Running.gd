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

var vertical_rotation

var base_rotation = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass 

func update(delta):
	# Handle all states
	if _state._controller.spin_entered:
		_state.update_state("Floor Spin")
	if _state._controller.pivot_entered and _state.current_speed > max_speed*.2:
		_state.update_state("FloorSlide")
		return
	if _state.attempting_dive:
		if _player.grappling:
			_state.update_state("ReelIn")
		else:
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
	# Handle Animation Tree
	_player.player_anim_tree["parameters/Run/Blend/blend_amount"] = _state.current_speed / max_speed
	if _state.attempting_throw:
		_state._throw()
	#_player.particles.emitting = true
	
	# Process all inputs
	grounded_movement_processing()
	look_forward()
	lean_into_turns()
	
	# Process all relevant timers
	
	#Process physics
	_state.velocity = _state.calculate_velocity(0, delta)
	
	pass

func reset():
	_state._air_drift_state = _state.not_air_drifting
	_state.snap_vector = Vector3.DOWN
	_state.velocity.y = 0
	_player.anim_tree.travel("Run")
	pass
