extends AerialMovement

#private variables
var _state_name = "Jump"
var current_jump_strength : float

var no_wall_jump : bool
@export var ground_pound_finished := false

#onready variables

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle all state logic
	if _state._jump_state == _state.ground_pound:
		if ground_pound_finished:
			_state.update_state("Falling")
		else:
			return
	
	if _state.attempting_dive and _state._jump_state != _state.dive:
		if _state._controller.input_strength > .2:
			_state._jump_state = _state.dive
			_state.update_state("Jump")
		else:
			_state._jump_state = _state.ground_pound
			_state.update_state("Jump")
		return
	match wall_collision_check():
		wall_collision.wallSlide:
			_state.update_state("WallSlide")
			return
		wall_collision.ledgeGrab:
			_state.update_state("LedgeGrab")
			return
	if _state._jump_state == _state.ground_pound:
		if not _player.player_anim.is_playing():
			_state.update_state("Falling")
		else:
			return
	if _state._controller._jump_state == _state._controller.jump_released and shorthop_timer == shorthop_buffer:
		_state.velocity.y *= .6
		_state.update_state("Falling")
		return
	if _state.velocity.y <= 0:
		_state.update_state("Falling")
		return
	if _state.attempting_throw and _state._jump_state != _state.dive:
		_state._throw()
	# Handle animation tree
	
	# Process movements
	if _state._jump_state == _state.spin_jump:
		spin_jump_drift()
	elif _state._jump_state != _state.dive:
		standard_aerial_drift()
	
	# Update all relevant counters
	shorthop_timer += 1
		
	# Process physics
	_state.velocity = _state.calculate_velocity(current_jump_gravity, delta)
	pass

func reset():
	_player.anim_tree.travel("Jump")
	match _state._jump_state:
		_state.jump:
			current_jump_gravity = _jump_gravity
			current_jump_strength = _jump_strength
			_player.player_anim_tree["parameters/Jump/playback"].start("Jump")
		_state.jump2: 
			current_jump_gravity = _jump2_gravity
			current_jump_strength = _jump2_strength
			_player.player_anim_tree["parameters/Jump/playback"].start("Jump2")
		_state.jump3: 
			current_jump_gravity = _jump3_gravity
			current_jump_strength = _jump3_strength
			_player.player_anim_tree["parameters/Jump/playback"].start("Side Flip")
		_state.spin_jump:
			_player.anim_tree.travel("Spinning")
			current_jump_gravity = _spin_jump_gravity
			current_jump_strength = _spin_jump_strength
		_state.side_flip:
			current_jump_gravity = _side_jump_gravity
			current_jump_strength = _side_jump_strength
			_player.player_anim_tree["parameters/Jump/playback"].start("Side Flip")
		_state.dive:
			current_jump_gravity = _dive_jump_gravity
			current_jump_strength = _dive_jump_strength
			_state.current_speed += dive_speed
			_state.move_direction = _state.camera_relative_movement
			_player.player_anim_tree["parameters/Jump/playback"].start("Dive")
		_state.rollout:
			_state.current_jump = 0
			current_jump_gravity = _dive_jump_gravity
			current_jump_strength = _dive_jump_strength
			_player.player_anim_tree["parameters/Jump/playback"].start("Rollout")
		_state.popper_bounce:
			current_jump_gravity = _side_jump_gravity
			current_jump_strength = _side_jump_strength
			_player.player_anim_tree["parameters/Jump/playback"].start("Jump")
		_state.ground_pound:
			current_jump_gravity = 0
			current_jump_strength = 0
			_player.velocity = Vector3.ZERO
			_state.velocity = Vector3.ZERO
			_state.current_speed = 0.0
			_player.player_anim_tree["parameters/Jump/playback"].start("Rollout")
		_: 
			current_jump_gravity = _jump_gravity
			current_jump_strength = _jump_strength
			_player.player_anim_tree["parameters/Jump/playback"].start("Jump")
	
	shorthop_timer = 0
	ground_pound_finished = false
	entering_jump_angle = _state.current_dir
	_state.snap_vector = Vector3.ZERO
	_state.velocity.y = current_jump_strength
	_state._player.velocity.y = current_jump_strength
	if _state.move_direction != Vector3.ZERO:
		_player.transform = _player.transform.looking_at(_player.global_transform.origin + _state.move_direction, Vector3.UP)
	pass
