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
var state_name = "Slammed"

var soundplayer = AudioStreamPlayer.new()

var frictionless_time := 5
var frictionless_timer := 0
# Called when the node enters the scene tree for the first time.
func _ready():
	soundplayer.bus = "Sound Effects"
	soundplayer.set_mix_target(AudioStreamPlayer.MIX_TARGET_CENTER)
	soundplayer.volume_db = -9
	add_child(soundplayer)
	state.state_dictionary[state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle state changes
	if state.current_speed <= .5:
		state.update_state("Running")
		return
	if (player.is_on_floor()):
		if state.ground_friction == 1 and frictionless_timer > frictionless_time:
			state.current_speed *= .95
		elif frictionless_timer > frictionless_time:
			state.current_speed *= state.ground_friction
	else:
		state.jump_state = state.jump
		state.update_state("Falling")
	frictionless_timer += 1
	# Handle animation tree
	
	# Process relevant timers
	
	# Handle inputs
	
	# Process Physics
	state.velocity = state.calculate_velocity(-9.8, delta)
	pass

func reset():
	state.anim_tree["parameters/conditions/jump"] = true
	state.anim_tree["parameters/Jump/conditions/dive"] = true
	state.current_speed = state.velocity.length()
	state.move_direction = state.velocity.normalized()
	frictionless_timer = 0
	state._reset_animation_parameters()
	var instance = load(landing_particles).instantiate()
	add_child(instance)
	instance.global_position = state.player.global_position
	soundplayer.set_stream(load("res://assets/sounds/actor noises/Jump Land.mp3"))
	soundplayer.play()
	state.snap_vector = Vector3.DOWN
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
