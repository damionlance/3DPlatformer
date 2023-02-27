extends AerialMovement

var _state_name = "SwingFromFriendo"

@onready var grapple = $"../../../GrappleRaycast"

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	
	pass # Replace with function body.

func update(_delta):
	if _controller._throw_state == 0:
		_player.grappling = false
		_state._jump_state = _state.jump
		_state.update_state("Falling")
		return
	if _state.attempting_dive:
		_state.update_state("ReelIn")
		return
	if _state.attempting_jump:
		_player.grappling = false
		_state._jump_state = _state.jump
		_state.update_state("Jump")
		return
	_state.current_speed = _state.velocity.length()
	_state.move_direction = _state.velocity.normalized()
	pass

func reset():
	_player.grappling = true
	_player.grapple_slider.linear_velocity = _player.velocity
	_state.velocity.y = 0
	pass
