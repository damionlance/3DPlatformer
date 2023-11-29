extends AerialMovement

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var state_name = "Falling"
var entering_jump_buttonstate
var current_fall_gravity
#onready variables
@onready var landing_particles = "res://scenes/particles/landing particles.tscn"

var coyote_time_timer := Timer.new()
var coyote_time_limit := 0.016667 * (5.0) #Frames!

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	add_child(coyote_time_timer)
	coyote_time_timer.one_shot = true
	pass # Replace with function body.

func update(delta):
	var delta_v = Vector3.ZERO
	# Handle state logic
	if raycasts.is_on_floor:
		state.update_state("Idle")
		return
	# Update relevant counters
	delta_v.y = -1
	# Process Physics
	player.delta_v = delta_v
	pass

func reset():
	match player.jump_state:
		player.jump:
			current_fall_gravity = constants._fall_gravity
		player.jump2: 
			current_fall_gravity = constants._fall2_gravity
		player.jump3: 
			current_fall_gravity = constants._fall3_gravity
		player.long_jump: 
			current_fall_gravity = constants._fall2_gravity/2
		player.spin_jump:
			player.velocity.y = 0
			current_fall_gravity = constants._spin_fall_gravity
		player.wall_spin:
			player.velocity.y = 0
			current_fall_gravity = constants._spin_fall_gravity
		player.side_flip:
			current_fall_gravity = constants._side_fall_gravity
		player.dive:
			#animation doesn't change for dives falling
			current_fall_gravity = constants._dive_fall_gravity
		player.rollout:
			#animation doesn't change for rollouts falling
			current_fall_gravity = constants._rollout_fall_gravity
		player.popper_bounce:
			current_fall_gravity = constants._side_fall_gravity
		player.ground_pound:
			current_fall_gravity = constants._fall_gravity
			player.velocity.y = constants.terminal_velocity
		player.bonk:
			current_fall_gravity = constants._fall_gravity
		_: 
			current_fall_gravity = constants._fall_gravity
	pass
