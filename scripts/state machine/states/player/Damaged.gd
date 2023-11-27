extends AerialMovement

#private variables
var state_name = "Damaged"
var current_jump_strength : float
var current_jump_gravity : float

var no_wall_jump : bool
@export var ground_pound_finished := false

#onready variables

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[state_name] = self
	pass # Replace with function body.

var timer := 20
var buffer := 0
var start_timer := false

var flashing := 0

func update(delta):
	if buffer == timer:
		player.remove_from_group("no_damage")
		player.visible = true
		state.update_state("Running")

		return
	elif start_timer:
		buffer += 1
	elif state.player.is_on_floor():
		start_timer = true

	if flashing == 5:
		if player.visible == false:
			player.visible = true
		else:
			player.visible = false
		flashing = 0
	else:
		flashing += 1
	# Handle animation tree
	
	# Process movements
	
	# Update all relevant counters

	# Process physics
	state.velocity = state.calculate_velocity(current_jump_gravity, delta)
	pass

func reset():
	player.add_to_group("no_damage")
	player.anim_tree.travel("Jump")
	current_jump_gravity = constants._jump_gravity
	current_jump_strength = constants._jump_strength
	player.player_anim_tree["parameters/Jump/playback"].start("Jump")
	flashing = 0
	buffer = 0
	start_timer = false

	ground_pound_finished = false
	state.velocity.y = current_jump_strength
	player.velocity.y = current_jump_strength
