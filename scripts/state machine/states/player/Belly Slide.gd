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
var state_name = "Belly Slide"

var steep_slope_timer := 0
var steep_slope_buffer := 5
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
	print("Hello!")
	var delta_v = Vector3.ZERO
#	if player.velocity.length() < 1 * delta:
#		state.update_state("Running")
#		return
	if controller.attempting_jump:
		player.jump_state = player.rollout
		state.update_state("Jump")
		return
	# Handle animation tree
	
	# Process relevant timers
	
	# Handle inputs
	
	delta_v = grounded_movement_processing(delta, delta_v)
	player.delta_v = delta_v
	# Process Physics
	player.snap_vector = -raycasts.average_floor_normal * 0.25
	pass

func reset(_delta):
	player.max_horizontal_velocity = 0.0
	player.look_at_velocity = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
