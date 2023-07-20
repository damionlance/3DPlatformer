extends AerialMovement

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Falling"
var entering_jump_button_state
var current_fall_gravity
#onready variables
@onready var landing_particles = "res://scenes/particles/landing particles.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle state logic
	if _state.attempting_dive and not (_state._jump_state == _state.dive or _state._jump_state == _state.rollout or _state._jump_state == _state.ground_pound):
		if _state._controller.input_strength > .2:
			_state._jump_state = _state.dive
			_state.update_state("Jump")
		else:
			_state._jump_state = _state.ground_pound
			_state.update_state("Jump")
		return
	if _player.is_on_floor():
		_state.consecutive_stationary_wall_jump = 0
		airdrifting = false
		_state.snap_vector = Vector3.DOWN
		if _state._jump_state == _state.dive:
			_state.update_state("Dive Floor")
		else:
			var instance = load(landing_particles).instantiate()
			add_child(instance)
			instance.global_position = _state._player.global_position
			_state.anim_tree["parameters/conditions/landed"] = true
			_state.anim_tree["parameters/conditions/running"] = true
			_state.anim_tree["parameters/conditions/ground pound"] = false
			_state.update_state("Running")
		_state.just_landed = true
		return
	match wall_collision_check():
		wall_collision.wallSlide:
			_state.update_state("WallSlide")
			airdrifting = false
			return
		wall_collision.ledgeGrab:
			_state.update_state("LedgeGrab")
			airdrifting = false
			return
		wall_collision.wallClimb:
			_state.update_state("WallClimb")
	if _state.attempting_throw and _state._jump_state != _state.dive:
		_state._throw()
	# Handle animation tree
	
	# Process movements
	if _state._jump_state == _state.ground_pound:
		pass
	elif _state._jump_state == _state.spin_jump:
		if entering_jump_button_state != _state._controller._jump_state:
			_state._jump_state = _state.jump
			_state.update_state("Falling")
			return
		spin_jump_drift()
	elif _state._jump_state != _state.dive:
		standard_aerial_drift()
	
	# Update relevant counters
	
	
	# Process Physics
	_state.velocity = _state.calculate_velocity(current_fall_gravity, delta)
	
	pass

func reset():
	entering_jump_button_state = _state._controller._jump_state
	entering_jump_angle = _state.current_dir
	_state.snap_vector = Vector3.ZERO
	match _state._jump_state:
		_state.jump:
			current_fall_gravity = constants._fall_gravity
			_state.anim_tree["parameters/conditions/fall"] = true
		_state.jump2: 
			current_fall_gravity = constants._fall2_gravity
		_state.jump3: 
			current_fall_gravity = constants._fall3_gravity
		_state.spin_jump:
			_state.velocity.y = 0
			current_fall_gravity = constants._spin_fall_gravity
			_state.anim_tree["parameters/conditions/fall"] = true
		_state.side_flip:
			current_fall_gravity = constants._side_fall_gravity
		_state.dive:
			#animation doesn't change for dives falling
			current_fall_gravity = constants._dive_fall_gravity
		_state.rollout:
			#animation doesn't change for rollouts falling
			current_fall_gravity = constants._rollout_fall_gravity
		_state.popper_bounce:
			current_fall_gravity = constants._side_fall_gravity
			_state.anim_tree["parameters/conditions/fall"] = true
		_state.ground_pound:
			current_fall_gravity = constants._fall_gravity
			_state.velocity.y = _state.terminal_velocity
			_player.velocity.y = _state.terminal_velocity
		_: 
			current_fall_gravity = constants._fall_gravity
	pass
