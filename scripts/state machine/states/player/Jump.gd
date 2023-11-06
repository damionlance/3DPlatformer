extends AerialMovement

#private variables
var _state_name = "Jump"
var current_jump_strength : float
var current_jump_gravity := 0.0

var dive_speed = 3

var no_wall_jump : bool
@export var ground_pound_finished := false

var sound_player = AudioStreamPlayer.new()
#onready variables

var entering_jump_button_state
# Called when the node enters the scene tree for the first time.
func _ready():
	sound_player.bus = "Sound Effects"
	sound_player.set_mix_target(AudioStreamPlayer.MIX_TARGET_CENTER)
	sound_player.volume_db = -9
	add_child(sound_player)
	
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle all state logic
	if _state._jump_state == _state.ground_pound:
		if ground_pound_finished:
			_state.update_state("Falling")
			return
	if _state._jump_state == _state.dive:
		if _player.is_on_wall():
			_state._jump_state = _state.bonk
			_state.update_state("Jump")
			return
	if not _state.restricted_movement:
		if _state.attempting_dive and _state._jump_state != _state.dive and _state._jump_state != _state.bonk:
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
	if _state._controller._jump_state == _state._controller.jump_released and constants.shorthop_timer == constants.shorthop_buffer:
		_state.velocity.y *= .5
	if _state.velocity.y < 0:
		_state.update_state("Falling")
		return
	if _state.attempting_throw and _state._jump_state != _state.dive:
		_state._throw()
	elif _state._jump_state == _state.spin_jump:
		spin_jump_drift()
	elif _state._jump_state != _state.dive:
		standard_aerial_drift()
	
	# Update all relevant counters
	constants.shorthop_timer += 1
		
	# Process physics
	_state.velocity = _state.calculate_velocity(current_jump_gravity, delta)
	pass

func reset():
	ground_pound_finished = false
	entering_jump_button_state = _state._controller._jump_state
	_state._reset_animation_parameters()
	_state.anim_tree["parameters/conditions/jump"] = true
	match _state._jump_state:
		_state.jump:
			current_jump_gravity = constants._jump_gravity
			current_jump_strength = constants._jump_strength
			_state.anim_tree["parameters/Jump/conditions/jump 1"] = true
			sound_player.set_stream(load("res://assets/sounds/actor noises/Jump 1.mp3"))
			sound_player.play()
		_state.jump2: 
			current_jump_gravity = constants._jump2_gravity
			current_jump_strength = constants._jump2_strength
			_state.anim_tree["parameters/Jump/conditions/jump 2"] = true
			sound_player.set_stream(load("res://assets/sounds/actor noises/Jump 2.mp3"))
			sound_player.play()
		_state.jump3: 
			current_jump_gravity = constants._jump3_gravity
			current_jump_strength = constants._jump3_strength
			_state.anim_tree["parameters/Jump/conditions/jump 3"] = true
			sound_player.set_stream(load("res://assets/sounds/actor noises/Jump 3.mp3"))
			sound_player.play()
		_state.long_jump:
			_state.current_speed = 18.0
			current_jump_gravity = constants._jump2_gravity/3
			current_jump_strength = constants._jump2_strength/2
			_state.anim_tree["parameters/Jump/conditions/jump 2"] = true
			sound_player.set_stream(load("res://assets/sounds/actor noises/Jump 2.mp3"))
			sound_player.play()
		_state.spin_jump:
			current_jump_gravity = constants._spin_jump_gravity
			current_jump_strength = constants._spin_jump_strength
			_state.anim_tree["parameters/conditions/jump"] = false
		_state.wall_spin:
			current_jump_gravity = constants._spin_fall_gravity
			current_jump_strength = constants._spin_jump_strength/3
			_state.anim_tree["parameters/conditions/spinning"] = true
			_state.anim_tree["parameters/conditions/jump"] = false
		_state.side_flip:
			current_jump_gravity = constants._side_jump_gravity
			current_jump_strength = constants._side_jump_strength
			_state.anim_tree["parameters/Jump/conditions/jump 3"] = true
			sound_player.set_stream(load("res://assets/sounds/actor noises/Jump 3.mp3"))
			sound_player.play()
		_state.dive:
			current_jump_gravity = constants._dive_jump_gravity
			current_jump_strength = constants._dive_jump_strength
			_state.current_speed += dive_speed
			_state.move_direction = _state.camera_relative_movement
			_state.anim_tree["parameters/Jump/conditions/dive"] = true
			sound_player.set_stream(load("res://assets/sounds/actor noises/Dive.mp3"))
			sound_player.play()
		_state.rollout:
			_state.current_jump = 0
			current_jump_gravity = constants._dive_jump_gravity
			current_jump_strength = constants._dive_jump_strength
			_state.anim_tree["parameters/Jump/conditions/roll out"] = true
			sound_player.set_stream(load("res://assets/sounds/actor noises/Side Flip.mp3"))
			sound_player.play()
		_state.popper_bounce:
			current_jump_gravity = constants._side_jump_gravity
			current_jump_strength = constants._side_jump_strength
			_state.anim_tree["parameters/Jump/conditions/jump 1"] = true
		_state.ground_pound:
			current_jump_gravity = 0
			current_jump_strength = 0
			_player.velocity = Vector3.ZERO
			_state.velocity = Vector3.ZERO
			_state.current_speed = 0.0
			_state.anim_tree["parameters/conditions/ground pound"] = true
			sound_player.set_stream(load("res://assets/sounds/actor noises/Side Flip.mp3"))
			sound_player.play()
		_state.bonk:
			current_jump_gravity = constants._jump_gravity
			current_jump_strength = constants._jump_strength
			_state.move_direction = -_state.move_direction
			_state.velocity = _state.move_direction * 5
			_state.current_dir = -_state.current_dir
			_state.current_speed = 12.5
			_state.anim_tree["parameters/Jump/conditions/bonk"] = true
			sound_player.set_stream(load("res://assets/sounds/actor noises/Side Flip.mp3"))
			sound_player.play()
		_: 
			current_jump_gravity = constants._jump_gravity
			current_jump_strength = constants._jump_strength
			_state.anim_tree["parameters/Jump/conditions/jump 1"] = true
	
	if _state.move_direction != Vector3.ZERO:
		_state.current_dir = _state.move_direction
	constants.shorthop_timer = 0
	entering_jump_angle = _state.camera_relative_movement
	_state.snap_vector = Vector3.ZERO
	_state.velocity.y = current_jump_strength
	_state._player.velocity.y = current_jump_strength
	if _state.move_direction != Vector3.ZERO:
		var temp = _player.transform.looking_at(_player.global_transform.origin + _state.move_direction, Vector3.UP)
		if temp != Transform3D():
			_player.transform = temp
	pass
