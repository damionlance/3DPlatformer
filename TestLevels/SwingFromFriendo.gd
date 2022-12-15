extends AerialMovement

var player2friendo
var initialLength

var _state_name = "SwingFromFriendo"
# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	_state.update_state(_state_name)
	pass # Replace with function body.

func update(delta):
	if _state.attempting_dive:
		_state.update_state("Dive")
		return
	if _state.attempting_jump:
		_state.update_state("Jump")
		return
	
	player2friendo = _player.global_transform.origin - _state.grapple_position
	print(initialLength)
	if initialLength < player2friendo.length():
		#_player.translation -= player2friendo.normalized()*(player2friendo.length()-initialLength)
		_state.velocity -= player2friendo.normalized()*(player2friendo.length()-initialLength)
	_state.velocity.y += _jump_gravity * delta
	
	pass

func reset():
	_state.velocity.y = 0
	player2friendo = _player.global_transform.origin - _state.grapple_position
	initialLength = player2friendo.length()
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
