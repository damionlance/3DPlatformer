extends AerialMovement


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "WallSlide"
var entering_angle : Vector3
var surface_normal : Vector3

var wall_bounce_buffer := 5
var wall_bounce_timer := 0

var forwards
var right

#onready variables

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	pass # Replace with function body.

func update(delta):
	wall_bounce_timer += 1
	
	if _player.is_on_floor():
		_state.update_state("Running")
		return
	if not _state._raycast_middle.is_colliding():
		_state._jump_state = _state.jump
		_state.update_state("Falling")
		return
	if wall_collision_check() == wall_collision.wallClimb:
		_state.update_state("WallClimb")
		return
	if wall_bounce_timer < wall_bounce_buffer:
		if  _state.attempting_jump and _state._controller._jump_state:
			_state.move_direction = _state.camera_relative_movement.normalized().bounce(surface_normal)
			if _state.current_speed + 0.25 > 12.5:
				_state.current_speed += 0.25
			else:
				_state.current_speed = 12.5
			_state._jump_state = _state.jump
			_state.update_state("Jump")
	else:
		if  _state.attempting_jump:
			directional_input_handling()
			_state.current_speed = 10
			_state._jump_state = _state.jump
			_state.update_state("Jump")
	_state.velocity = _state.calculate_velocity(-10, delta)
	pass

func directional_input_handling():
	var dir = _state.camera_relative_movement.normalized()
	if _state._controller.input_strength == 0:
		_state.move_direction = surface_normal
	elif dir.dot(surface_normal) < 0:
		_state.move_direction = dir.bounce(surface_normal)
	else:
		_state.move_direction = dir

func reset():
	_player.player_anim_tree["parameters/Jump/playback"].travel("Wall Slide")
	entering_angle = Vector3(_state.velocity.x,0, _state.velocity.z).normalized()
	if entering_angle == Vector3.ZERO:
		_state.consecutive_stationary_wall_jump += 1
	wall_bounce_timer = 0
	_state.velocity = Vector3.ZERO
	surface_normal = _player.get_last_slide_collision().get_normal()
	surface_normal.y = 0
	_state.move_direction = -surface_normal
	_state.snap_vector = -surface_normal
	_player.transform = _player.transform.looking_at(_player.global_position - surface_normal, Vector3.UP)
	return
