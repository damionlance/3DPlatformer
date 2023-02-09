extends "aerial_movement.gd"

class_name WallSlide


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "WallSlide"
var _keys
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
	
	if wall_bounce_timer < wall_bounce_buffer:
		if  _state.attempting_jump and _state._controller._jump_state:
			surface_normal.y = 0
			surface_normal = surface_normal.normalized()
			_state.move_direction = entering_angle.bounce(surface_normal)
			if _state.current_speed + 0.25 > 12.5:
				_state.current_speed += 0.25
			else:
				_state.current_speed = 12.5
			_state._jump_state = _state.jump
			_state.update_state("Jump")
	else:
		if  _state.attempting_jump:
			surface_normal.y = 0
			surface_normal = surface_normal.normalized()
			directional_input_handling()
			_state.current_speed = 10
			_state._jump_state = _state.jump
			_state.update_state("Jump")
	_state.velocity = _state.calculate_velocity(-10, delta)
	pass

func directional_input_handling():
	var dir = _state.camera_relative_movement.normalized()
	if dir.dot(surface_normal) < 0 or _state._controller.input_strength < .001:
		_state.move_direction = entering_angle.bounce(surface_normal)
	else:
		_state.move_direction = dir

func reset():
	if _player.player_anim_tree != null:
		_player.player_anim_tree["parameters/Jump/playback"].travel("Wall Slide")
	
	entering_angle = Vector3(_state.velocity.x,0, _state.velocity.z)
	
	wall_bounce_timer = 0
	_state.current_speed = 1
	_state.velocity = Vector3.ZERO
	var position = _player.get_last_slide_collision().position - _player.global_translation
	position.y = 0
	surface_normal = -position.normalized()
	_state.move_direction = position.normalized()
	_state.snap_vector = position.normalized()
	_player.transform = _player.transform.looking_at(_player.global_transform.origin - surface_normal, Vector3.UP)
	return
	
	
	if _state._raycast_left == null:
		return
	var collisionLeft = _state._raycast_left.get_collision_normal()
	var collisionRight = _state._raycast_right.get_collision_normal()
	if (collisionLeft - collisionRight).length() < 0.001: 
		surface_normal = collisionLeft
	elif not _state._raycast_left.is_colliding():
		surface_normal = collisionRight
	elif not _state._raycast_right.is_colliding():
		surface_normal = collisionLeft
	else:
		var leftDot = collisionLeft.dot(entering_angle)
		var rightDot = collisionRight.dot(entering_angle)
		surface_normal = collisionLeft if leftDot < rightDot else collisionRight
	_state.snap_vector = -surface_normal
	_state.move_direction = _state.snap_vector
	_player.transform = _player.transform.looking_at(_player.global_transform.origin + surface_normal, Vector3.UP)
	pass
