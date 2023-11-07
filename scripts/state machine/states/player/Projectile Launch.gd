extends AerialMovement
var current_position := Vector3.ZERO
var target_position := Vector3.ZERO

var time_of_launch := 2000.0

var current_jump_gravity = constants._jump_gravity
var launched := false
#private variables
var _state_name = "Projectile Launch"

@export var ground_pound_finished := false

var sound_player = AudioStreamPlayer.new()
#onready variables
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
	if _player.is_on_wall():
		_state._jump_state = _state.bonk
		_state.update_state("Jump")
		return
	if _player.is_on_floor():
		_state.update_state("Running")
		return
	
	if current_position != Vector3.ZERO:
		if launched:
			_state.velocity = _state.calculate_velocity(current_jump_gravity, delta)
		else:
			var total_distance = (target_position - current_position)
			print("Total distance: ", total_distance.length())
			var horizontal_velocity = total_distance/time_of_launch
			print("Horizontal velocity: ", horizontal_velocity.length())
			var height_offset = target_position.y - current_position.y
			var angle = 0.5 * asin((current_jump_gravity*total_distance.length())/pow(horizontal_velocity.length(),2))
			print("Launch angle in degrees: ", rad_to_deg(angle))
			var initial_velocity = (1/cos(angle))
			initial_velocity *= sqrt((current_jump_gravity*.5*pow(total_distance.length(),2))/(total_distance.length()*tan(angle) + height_offset))
			print("Initial velocity: ", initial_velocity)
			_state.velocity = Vector3(initial_velocity*cos(angle), -initial_velocity * sin(angle), 0)
			var rotation_angle = atan2(target_position.z-current_position.z, target_position.x-current_position.x)
			print("Aimed angle in degrees: ", rad_to_deg(rotation_angle))
			_state.velocity = _state.velocity.rotated(Vector3.UP, rotation_angle)
			_state.velocity.z *= -1
			_player.velocity = _state.velocity
			_state.current_speed = Vector3(_state.velocity.x, 0, _state.velocity.z).length()
			_state.move_direction = Vector3(_state.velocity.x, 0, _state.velocity.z).normalized()
			launched = true
	# Process physics
	pass

func reset():
	launched = false
	ground_pound_finished = false
	_state._reset_animation_parameters()
	_state.anim_tree["parameters/conditions/jump"] = true
	
	if _state.move_direction != Vector3.ZERO:
		_state.current_dir = _state.move_direction
	constants.shorthop_timer = 0
	entering_jump_angle = _state.camera_relative_movement
	_state.snap_vector = Vector3.ZERO
	if _state.move_direction != Vector3.ZERO:
		var temp = _player.transform.looking_at(_player.global_transform.origin + _state.move_direction, Vector3.UP)
		if temp != Transform3D():
			_player.transform = temp
