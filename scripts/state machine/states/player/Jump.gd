extends AerialMovement

#private variables
var state_name = "Jump"
var current_jump_strength : float
var current_jump_gravity := 0.0

var consecutive_jump_timer : Timer
var consecutive_jump_buffer := 0.083
var consecutive_jump_position := 0

var long_jump_speed = 20
var dive_speed = 15
var dive_acceleration = 2.0

var no_wall_jump : bool
@export var ground_pound_finished := false

var soundplayer = AudioStreamPlayer.new()
#onready variables
var entering_jump_buttonstate
# Called when the node enters the scene tree for the first time.
func _ready():
	consecutive_jump_timer = Timer.new()
	consecutive_jump_timer.one_shot = true
	consecutive_jump_timer.name = "Consecutive Jump Timer"
	add_child(consecutive_jump_timer)
	
	soundplayer.bus = "Sound Effects"
	soundplayer.set_mix_target(AudioStreamPlayer.MIX_TARGET_CENTER)
	soundplayer.volume_db = -9
	add_child(soundplayer)
	
	
	state.state_dictionary[state_name] = self
	pass # Replace with function body.

func update(delta):
	
	delta_v = Vector3.ZERO
	# Handle all state logic
	if controller.attempting_dive and player.jump_state != player.dive:
		player.jump_state = player.dive
		state.update_state("Jump")
		return
	if player.velocity.y < 0:
		state.update_state("Falling")
		return
	if raycasts.is_on_wall:
		state.update_state("Decide Wall Interaction")
		return
	# Update all relevant counters
	if player.jump_state < 4:
		delta_v = regular_aerial_movement_processing()
	# Process physics
	delta_v.y = current_jump_gravity * delta
	player.delta_v = delta_v

func reset(_delta):
	ground_pound_finished = false
	entering_jump_buttonstate = player.jump_state
	
	if player.jump_state == 0:
		consecutive_jump_position += 1
		player.jump_state += 1
	
	
#	state._reset_animation_parameters()
#	state.anim_tree["parameters/conditions/jump"] = true
	match player.jump_state:
		player.jump:
			current_jump_gravity = constants._jump_gravity
			current_jump_strength = constants._jump_strength
#			state.anim_tree["parameters/Jump/conditions/jump 1"] = true
#			soundplayer.set_stream(load("res://assets/sounds/actor noises/Jump 1.mp3"))
#			soundplayer.play()
		player.jump2: 
			current_jump_gravity = constants._jump2_gravity
			current_jump_strength = constants._jump2_strength
#			state.anim_tree["parameters/Jump/conditions/jump 2"] = true
#			soundplayer.set_stream(load("res://assets/sounds/actor noises/Jump 2.mp3"))
#			soundplayer.play()
		player.jump3: 
			current_jump_gravity = constants._jump3_gravity
			current_jump_strength = constants._jump3_strength
#			soundplayer.set_stream(load("res://assets/sounds/actor noises/Jump 3.mp3"))
#			soundplayer.play()
		player.long_jump:
			current_jump_gravity = constants._jump2_gravity/3
			current_jump_strength = constants._jump2_strength/2
			player.velocity = controller.camera_relative_movement * long_jump_speed * _delta
#			soundplayer.set_stream(load("res://assets/sounds/actor noises/Jump 2.mp3"))
#			soundplayer.play()
		player.spin_jump:
			current_jump_gravity = constants._spin_jump_gravity
			current_jump_strength = constants._spin_jump_strength
#			state.anim_tree["parameters/conditions/jump"] = false
		player.wall_spin:
			current_jump_gravity = constants._spin_fall_gravity
			current_jump_strength = constants._spin_jump_strength/3
#			state.anim_tree["parameters/conditions/spinning"] = true
#			state.anim_tree["parameters/conditions/jump"] = false
		player.side_flip:
			current_jump_gravity = constants._side_jump_gravity
			current_jump_strength = constants._side_jump_strength
#			state.anim_tree["parameters/Jump/conditions/jump 3"] = true
#			soundplayer.set_stream(load("res://assets/sounds/actor noises/Jump 3.mp3"))
#			soundplayer.play()
		player.dive:
			current_jump_gravity = constants._dive_jump_gravity
			current_jump_strength = constants._dive_jump_strength
			if player.velocity.length() < dive_speed * _delta:
				player.velocity = controller.camera_relative_movement * dive_speed * _delta
			else:
				player.velocity = controller.camera_relative_movement * ((dive_acceleration * _delta) + player.velocity.length())
#			state.anim_tree["parameters/Jump/conditions/dive"] = true
#			soundplayer.set_stream(load("res://assets/sounds/actor noises/Dive.mp3"))
#			soundplayer.play()
		player.rollout:
			current_jump_gravity = constants._dive_jump_gravity
			current_jump_strength = constants._dive_jump_strength
#			state.anim_tree["parameters/Jump/conditions/roll out"] = true
#			soundplayer.set_stream(load("res://assets/sounds/actor noises/Side Flip.mp3"))
#			soundplayer.play()
		player.popper_bounce:
			current_jump_gravity = constants._side_jump_gravity
			current_jump_strength = constants._side_jump_strength
#			state.anim_tree["parameters/Jump/conditions/jump 1"] = true
		player.ground_pound:
			current_jump_gravity = 0
			current_jump_strength = 0
			player.velocity = Vector3.ZERO
			state.velocity = Vector3.ZERO
			state.current_speed = 0.0
#			state.anim_tree["parameters/conditions/ground pound"] = true
#			soundplayer.set_stream(load("res://assets/sounds/actor noises/Side Flip.mp3"))
#			soundplayer.play()
		player.bonk:
			current_jump_gravity = constants._jump_gravity
			current_jump_strength = constants._jump_strength
#			state.move_direction = -state.move_direction
#			state.velocity = state.move_direction * 5
#			state.current_dir = -state.current_dir
#			state.current_speed = 12.5
#			state.anim_tree["parameters/Jump/conditions/bonk"] = true
#			soundplayer.set_stream(load("res://assets/sounds/actor noises/Side Flip.mp3"))
#			soundplayer.play()
		_: 
			current_jump_gravity = constants._jump_gravity
			current_jump_strength = constants._jump_strength
#			state.anim_tree["parameters/Jump/conditions/jump 1"] = true
	player.look_at_velocity = false
	constants.shorthop_timer = 0
	entering_jump_angle = controller.camera_relative_movement
	player.snap_vector = Vector3.ZERO
	player.velocity.y = current_jump_strength * _delta
	pass
