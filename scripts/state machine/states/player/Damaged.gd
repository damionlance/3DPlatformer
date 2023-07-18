extends AerialMovement

#private variables
var _state_name = "Damaged"
var current_jump_strength : float
var current_jump_gravity : float

var no_wall_jump : bool
@export var ground_pound_finished := false

#onready variables

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

var timer := 20
var buffer := 0
var start_timer := false

var flashing := 0

func update(delta):
	if buffer == timer:
		_player.remove_from_group("no_damage")
		_player.visible = true
		_state.update_state("Running")

		return
	elif start_timer:
		buffer += 1
	elif _state._player.is_on_floor():
		start_timer = true

	if flashing == 5:
		if _player.visible == false:
			_player.visible = true
		else:
			_player.visible = false
		flashing = 0
	else:
		flashing += 1
	# Handle animation tree
	
	# Process movements
	
	# Update all relevant counters

	# Process physics
	_state.velocity = _state.calculate_velocity(current_jump_gravity, delta)
	pass

func reset():
	_player.add_to_group("no_damage")
	_player.anim_tree.travel("Jump")
	current_jump_gravity = constants._jump_gravity
	current_jump_strength = constants._jump_strength
	_player.player_anim_tree["parameters/Jump/playback"].start("Jump")
	flashing = 0
	buffer = 0
	start_timer = false

	ground_pound_finished = false
	_state.velocity.y = current_jump_strength
	_player.velocity.y = current_jump_strength
