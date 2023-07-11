extends GroundedMovement


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Dive Floor"

var sound_player = AudioStreamPlayer.new()
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
		if _state.ground_friction == 1:
			_state.current_speed *= .95
		else:
			_state.current_speed *= _state.ground_friction
		if _state.attempting_jump:
			_state._jump_state = _state.rollout
			_state.update_state("Jump")
			return
		if _state.current_speed < .01:
			_state.current_speed = 0
	else:
		_state._jump_state = _state.jump
		_state.update_state("Falling")
	
	# Handle animation tree
	
	# Process relevant timers
	
	# Handle inputs
	
	# Process Physics
	_state.velocity = _state.calculate_velocity(-9.8, delta)
	pass

func reset():
	sound_player.set_stream(load("res://assets/sounds/actor noises/Jump Land.mp3"))
	sound_player.play()
	_state.snap_vector = Vector3.DOWN
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
