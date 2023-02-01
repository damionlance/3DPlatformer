extends "aerial_movement.gd"

class_name Rollout

#private variables
var _state_name = "Rollout"

#onready variables

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	# Handle all state logic
	match wall_collision_check():
		wall_collision.wallSlide:
			_state.update_state("WallSlide")
			return
		wall_collision.ledgeGrab:
			_state.update_state("LedgeGrab")
			return
	if _state.velocity.y < -6: #-6 is faster than the highest y velocity player experiences during a grounded rollout
		_state.update_state("Falling")
		return
	if _player.is_on_floor():
		_state.update_state("Running")
		return
	# Handle animation tree
	
	# Process movements
	standard_aerial_drift()
	
	# Update all relevant counters
	shorthop_timer += 1
		
	# Process physics
		
	_state.velocity = _state.calculate_velocity(_jump_gravity, delta)
	pass

func reset():
	_player.player_anim_tree["parameters/Dive/playback"].travel("Rollout")
	if _state.just_landed:
		current_jump += 1
	else:
		current_jump = 1
	
	shorthop_timer = 0
	entering_jump_angle = _state._controller.movement_direction
	_state.snap_vector = Vector3.ZERO
	_state.velocity.y = _jump_strength / 2
	_player.transform = _player.transform.looking_at(_player.global_transform.origin + _state.move_direction, Vector3.UP)
	pass
