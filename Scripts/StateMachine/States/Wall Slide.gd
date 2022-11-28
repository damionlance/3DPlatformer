extends Node

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

#onready variables
onready var _state = get_parent()
onready var _player = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	_state.update_state(_state_name)
	pass # Replace with function body.

func update(delta):
	_player.player_anim.play("Idle")
	#player.animation_player.play("Idle")
	_state.move_direction = _state.snap_vector
	_state.current_speed = 2
	if _player.is_on_floor():
		_state.update_state("Idle")
		return
	if  _state._jump_state == _state.jump_pressed:
		_state.move_direction = entering_angle.bounce(surface_normal)
		_state.current_speed = _state.max_speed
		_state.update_state("Jump")
		_state._allow_wall_jump = false
	_state.velocity = _state.calculate_velocity(-1, delta)
	pass

func reset():
	_state.velocity = Vector3.ZERO
	entering_angle = Vector3(_state.move_direction.x,0, _state.move_direction.z).normalized()
	_state.current_speed = 0
	_state.snap_vector = -_state.collision_normal
	surface_normal = _state.collision_normal
	_player.transform = _player.transform.looking_at(surface_normal, Vector3.UP)
	pass
