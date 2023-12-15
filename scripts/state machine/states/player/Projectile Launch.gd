extends AerialMovement
var current_position := Vector3.ZERO
var target_position := Vector3.ZERO
var launched := false
#private variables
var state_name = "Projectile Launch"

@export var ground_pound_finished := false

var soundplayer = AudioStreamPlayer.new()
#onready variables
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
	if player.is_on_wall():
		state.jump_state = state.bonk
		state.update_state("Jump")
		return
	if player.is_on_floor():
		state.update_state("Running")
		return
	
	if current_position != Vector3.ZERO:
		if launched:
			state.velocity = state.calculate_velocity(state.terminal_velocity, delta)
		else:
			calculate_launch_angle_and_velocity()
			
			launched = true
	# Process physics
	pass

func calculate_launch_angle_and_velocity():
	
	var planar_target = Vector3(target_position.x, 0, target_position.z)
	var planar_position = Vector3(current_position.x, 0, current_position.z)
	var target_height = (target_position.y - current_position.y)
	var gravity = state.terminal_velocity
	var delta_x = (planar_target-planar_position).length()
	var Viy
	var Vix
	var t1
	var t0
	var delta_y = 0 # for planar launches
	if target_position.y >= current_position.y:
		delta_y = 5 + target_height
		t1 = sqrt(5/(.5 * -gravity))
		t0 = sqrt(delta_y/(.5 * -gravity))
		Viy = -gravity * t0
		Vix = delta_x/(t0+t1)
	else:
		pass
	
	var rotation_angle = atan2(planar_target.z-planar_position.z, planar_target.x - planar_position.x)
	var Vi = Vector3(Vix, Viy, 0).rotated(Vector3.UP, rotation_angle)
	Vi.z *= -1
	var horizontal_velocity = Vi
	horizontal_velocity.y = 0
	state.move_direction = horizontal_velocity.normalized()
	state.current_speed = horizontal_velocity.length()
	state.velocity.y = Viy

func reset():
	launched = false
	ground_pound_finished = false
	state._reset_animation_parameters()
	state.anim_tree["parameters/conditions/jump"] = true
	
	if state.move_direction != Vector3.ZERO:
		state.current_dir = state.move_direction
	constants.shorthop_timer = 0
	entering_jump_angle = state.camera_relative_movement
	state.snap_vector = Vector3.ZERO
	if state.move_direction != Vector3.ZERO:
		var temp = player.transform.looking_at(player.global_transform.origin + state.move_direction, Vector3.UP)
		if temp != Transform3D():
			player.transform = temp