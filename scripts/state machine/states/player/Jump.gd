extends AerialMovement

#private variables
var _state_name = "Jump"
var current_jump_strength : float
var current_jump_gravity := 0.0

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
		await _state.anim_tree.animation_finished
		_state.update_state("Falling")
	if not _state.restricted_movement:
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
	if _state._controller._jump_state == _state._controller.jump_released and constants.shorthop_timer == constants.shorthop_buffer:
		_state.velocity.y *= .6
		_state.update_state("Falling")
		return
	if _state.velocity.y <= 0:
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
	airdrifting = false
	ground_pound_finished = false
	entering_jump_button_state = _state._controller._jump_state
	_state.anim_tree["parameters/conditions/jump"] = true
	_state.anim_tree["parameters/conditions/running"] = false
	_state.anim_tree["parameters/conditions/landed"] = false
	_state.anim_tree["parameters/Jump/conditions/dive"] = false
	_state.anim_tree["parameters/Jump/conditions/roll out"] = false
	_state.anim_tree["parameters/Jump/conditions/jump 1"] = false
	_state.anim_tree["parameters/Jump/conditions/jump 2"] = false
	_state.anim_tree["parameters/Jump/conditions/jump 3"] = false
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
		_state.spin_jump:
			_player.anim_tree.travel("Spinning")
			current_jump_gravity = constants._spin_jump_gravity
			current_jump_strength = constants._spin_jump_strength
			_state.anim_tree["parameters/Jump/conditions/jump 3"] = true
		_state.side_flip:
			current_jump_gravity = constants._side_jump_gravity
			current_jump_strength = constants._side_jump_strength
			_state.anim_tree["parameters/Jump/conditions/jump 3"] = true
			sound_player.set_stream(load("res://assets/sounds/actor noises/Jump 3.mp3"))
			sound_player.play()
		_state.dive:
			current_jump_gravity = constants._dive_jump_gravity
			current_jump_strength = constants._dive_jump_strength
			_state.current_speed += constants.dive_speed
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
		_: 
			current_jump_gravity = constants._jump_gravity
			current_jump_strength = constants._jump_strength
			_state.anim_tree["parameters/Jump/conditions/jump 1"] = true
	
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
