extends AerialMovement

class_name Dive


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Dive"

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle animation tree
	_player.anim_tree.travel("Floor Slide")
	
	# Process relevant timers
	shorthop_timer += 1
	
	# Handle inputs
	standard_aerial_drift()
	
	# Handle state changes
	if _player.is_on_floor():
		_state.update_state("Dive Floor")
	# Process Physics
	_state.velocity = _state.calculate_velocity(_jump_gravity, delta)
	
	
	pass

func reset():
	shorthop_timer = 0
	entering_jump_angle = _state._controller.movement_direction
	_state.move_direction = _state.camera_relative_movement
	_state.snap_vector = Vector3.ZERO
	_state.velocity.y = _jump_strength*.75
	_state.current_speed += dive_speed
	_player.transform = _player.transform.looking_at(_player.global_transform.origin + _state.move_direction, Vector3.UP)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
