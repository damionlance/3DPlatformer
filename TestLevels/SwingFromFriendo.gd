extends AerialMovement

var _state_name = "SwingFromFriendo"

onready var grapple = $"../../GrappleRaycast"

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	
	pass # Replace with function body.

func update(delta):
	if _controller._throw_state == 0:
		_state.update_state("SideFlip")
		_player.grappling = false
		return
	if _state.attempting_dive:
		_player.grappling = false
		_state.update_state("Dive")
		return
	if _state.attempting_jump:
		_player.grappling = false
		_state.update_state("Jump")
		return
	_state.snap_vector = grapple.cast_to.normalized()
	_state.velocity = _state.grapple_velocity(_jump_gravity, delta)
	_state.current_speed = _state.velocity.length()
	pass

func reset():
	_player.grappling = true
	_state.velocity.y = 0
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
