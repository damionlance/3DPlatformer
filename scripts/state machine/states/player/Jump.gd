extends AerialMovement

#private variables
var state_name = "Jump"
var current_jump_strength : float
var current_jump_gravity := 0.0

var dive_speed = 3

var no_wall_jump : bool
@export var ground_pound_finished := false

var soundplayer = AudioStreamPlayer.new()
#onready variables

var entering_jump_buttonstate
# Called when the node enters the scene tree for the first time.
func _ready():
	soundplayer.bus = "Sound Effects"
	soundplayer.set_mix_target(AudioStreamPlayer.MIX_TARGET_CENTER)
	soundplayer.volume_db = -9
	add_child(soundplayer)
	
	state.state_dictionary[state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle all state logic
	
	# Update all relevant counters
		
	# Process physics
	pass

func reset():
	ground_pound_finished = false
	entering_jump_buttonstate = state.controller.jumpstate
	state._reset_animation_parameters()
	state.anim_tree["parameters/conditions/jump"] = true
	match state.jumpstate:
		state.jump:
			current_jump_gravity = constants._jump_gravity
			current_jump_strength = constants._jump_strength
			state.anim_tree["parameters/Jump/conditions/jump 1"] = true
			soundplayer.set_stream(load("res://assets/sounds/actor noises/Jump 1.mp3"))
			soundplayer.play()
		state.jump2: 
			current_jump_gravity = constants._jump2_gravity
			current_jump_strength = constants._jump2_strength
			state.anim_tree["parameters/Jump/conditions/jump 2"] = true
			soundplayer.set_stream(load("res://assets/sounds/actor noises/Jump 2.mp3"))
			soundplayer.play()
		state.jump3: 
			current_jump_gravity = constants._jump3_gravity
			current_jump_strength = constants._jump3_strength
			state.anim_tree["parameters/Jump/conditions/jump 3"] = true
			soundplayer.set_stream(load("res://assets/sounds/actor noises/Jump 3.mp3"))
			soundplayer.play()
		state.long_jump:
			state.current_speed = 18.0
			current_jump_gravity = constants._jump2_gravity/3
			current_jump_strength = constants._jump2_strength/2
			state.anim_tree["parameters/Jump/conditions/jump 2"] = true
			soundplayer.set_stream(load("res://assets/sounds/actor noises/Jump 2.mp3"))
			soundplayer.play()
		state.spin_jump:
			current_jump_gravity = constants._spin_jump_gravity
			current_jump_strength = constants._spin_jump_strength
			state.anim_tree["parameters/conditions/jump"] = false
		state.wall_spin:
			current_jump_gravity = constants._spin_fall_gravity
			current_jump_strength = constants._spin_jump_strength/3
			state.anim_tree["parameters/conditions/spinning"] = true
			state.anim_tree["parameters/conditions/jump"] = false
		state.side_flip:
			current_jump_gravity = constants._side_jump_gravity
			current_jump_strength = constants._side_jump_strength
			state.anim_tree["parameters/Jump/conditions/jump 3"] = true
			soundplayer.set_stream(load("res://assets/sounds/actor noises/Jump 3.mp3"))
			soundplayer.play()
		state.dive:
			current_jump_gravity = constants._dive_jump_gravity
			current_jump_strength = constants._dive_jump_strength
			state.current_speed += dive_speed
			state.move_direction = state.camera_relative_movement
			state.anim_tree["parameters/Jump/conditions/dive"] = true
			soundplayer.set_stream(load("res://assets/sounds/actor noises/Dive.mp3"))
			soundplayer.play()
		state.rollout:
			state.current_jump = 0
			current_jump_gravity = constants._dive_jump_gravity
			current_jump_strength = constants._dive_jump_strength
			state.anim_tree["parameters/Jump/conditions/roll out"] = true
			soundplayer.set_stream(load("res://assets/sounds/actor noises/Side Flip.mp3"))
			soundplayer.play()
		state.popper_bounce:
			current_jump_gravity = constants._side_jump_gravity
			current_jump_strength = constants._side_jump_strength
			state.anim_tree["parameters/Jump/conditions/jump 1"] = true
		state.ground_pound:
			current_jump_gravity = 0
			current_jump_strength = 0
			player.velocity = Vector3.ZERO
			state.velocity = Vector3.ZERO
			state.current_speed = 0.0
			state.anim_tree["parameters/conditions/ground pound"] = true
			soundplayer.set_stream(load("res://assets/sounds/actor noises/Side Flip.mp3"))
			soundplayer.play()
		state.bonk:
			current_jump_gravity = constants._jump_gravity
			current_jump_strength = constants._jump_strength
			state.move_direction = -state.move_direction
			state.velocity = state.move_direction * 5
			state.current_dir = -state.current_dir
			state.current_speed = 12.5
			state.anim_tree["parameters/Jump/conditions/bonk"] = true
			soundplayer.set_stream(load("res://assets/sounds/actor noises/Side Flip.mp3"))
			soundplayer.play()
		_: 
			current_jump_gravity = constants._jump_gravity
			current_jump_strength = constants._jump_strength
			state.anim_tree["parameters/Jump/conditions/jump 1"] = true
	
	if state.move_direction != Vector3.ZERO:
		state.current_dir = state.move_direction
	constants.shorthop_timer = 0
	entering_jump_angle = state.camera_relative_movement
	state.snap_vector = Vector3.ZERO
	state.velocity.y = current_jump_strength
	state.player.velocity.y = current_jump_strength
	if state.move_direction != Vector3.ZERO:
		var temp = player.transform.looking_at(player.global_transform.origin + state.move_direction, Vector3.UP)
		if temp != Transform3D():
			player.transform = temp
	pass
