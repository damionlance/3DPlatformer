extends GroundedMovement


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

@onready var landing_particles = "res://scenes/particles/landing particles.tscn"
#private variables
var _state_name = "Dive Floor"

var sound_player = AudioStreamPlayer.new()

var frictionless_time := 5
var frictionless_timer := 0
# Called when the node enters the scene tree for the first time.
func _ready():
	sound_player.bus = "Sound Effects"
	sound_player.set_mix_target(AudioStreamPlayer.MIX_TARGET_CENTER)
	sound_player.volume_db = -9
	add_child(sound_player)
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle state changes
	if _state.current_speed <= .5:
		_state.update_state("Running")
		return
	if (_player.is_on_floor()):
		if _state.pivot_allowed:
			_state.update_state("FloorSlide")
		if _state.ground_friction == 1 and frictionless_timer > frictionless_time:
			_state.current_speed *= .95
		elif frictionless_timer > frictionless_time:
			_state.current_speed *= _state.ground_friction
		if _state.attempting_jump:
			if _state.spin_allowed:
				print(_state.move_direction)
				_state._jump_state = _state.wall_spin
				_state.update_state("Jump")
				return
			_state._jump_state = _state.rollout
			_state.update_state("Jump")
			return
		if _state.current_speed < .01:
			_state.current_speed = 0
	else:
		_state._jump_state = _state.jump
		_state.update_state("Falling")
	frictionless_timer += 1
	# Handle animation tree
	
	# Process relevant timers
	
	# Handle inputs
	
	# Process Physics
	_state.velocity = _state.calculate_velocity(-9.8, delta)
	pass

func reset():
	frictionless_timer = 0
	_state._reset_animation_parameters()
	var instance = load(landing_particles).instantiate()
	add_child(instance)
	instance.global_position = _state._player.global_position
	sound_player.set_stream(load("res://assets/sounds/actor noises/Jump Land.mp3"))
	sound_player.play()
	_state.snap_vector = Vector3.DOWN
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
