extends AerialMovement

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
	_state.update_state(_state_name)
	pass # Replace with function body.

func update(delta):
	_player.anim_tree.travel("Wall Slide")
	#player.animation_player.play("Idle")
	_state.move_direction = _state.snap_vector
	_state.current_speed = 2
	
	wall_bounce_timer += 1
	
	if _player.is_on_floor():
		_state.update_state("Idle")
		return
	
	if wall_bounce_timer < wall_bounce_buffer:
		if  _state.attempting_jump:
			_state.move_direction = entering_angle.bounce(surface_normal)
			if _state.current_speed + 0.25 > 12.5:
				_state.current_speed += 0.25
			else:
				_state.current_speed = 12.5
			_state.update_state("Jump")
	else:
		if  _state.attempting_jump:
			directional_input_handling()
			_state.current_speed = 10
			_state.update_state("Jump")
	_state.velocity = _state.calculate_velocity(-1, delta)
	pass

func directional_input_handling():
	var dir = _state.camera_relative_movement.normalized()
	if dir.dot(surface_normal) < 0 or _state._controller.input_strength < .001:
		_state.move_direction = entering_angle.bounce(surface_normal)
	else:
		_state.move_direction = dir

func reset():
	wall_bounce_timer = 0
	_state.current_speed = 0
	_state.velocity = Vector3.ZERO
	entering_angle = Vector3(_state.move_direction.x,0, _state.move_direction.z)
	
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
	_player.transform = _player.transform.looking_at(_player.global_transform.origin + surface_normal, Vector3.UP)
	pass
