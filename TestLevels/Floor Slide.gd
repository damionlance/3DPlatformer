extends GroundedMovement

class_name FloorSlide


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#private variables
var _state_name = "FloorSlide"
var _keys

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	_state.update_state(_state_name)
	pass # Replace with function body.

func update(delta):
	_player.anim_tree.travel("Floor Skid")
	
	_state._air_drift_state = _state.not_air_drifting
	#_state.current_speed *= .95
	
	if _state.velocity.length() < .5:
		_state.update_state("Idle")
		_state.attempting_pivot = false
		return
	
	if not _player.is_on_floor():
		_state.update_state("Falling")
		return
	if  _state._jump_state == _state.jump_pressed:
		print("DO A SIDE FLIP")
		return
	
	_state.velocity = _state.calculate_velocity(0, delta)
	pass

func reset():
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
