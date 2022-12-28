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
	pass # Replace with function body.

func update(delta):
	print("Hey!")
	if _state.current_speed < .5:
		_state.update_state("Running")
		return
	
	if not _player.is_on_floor():
		_state.update_state("Falling")
		return
	if  _state.attempting_jump:
		_state.update_state("SideFlip")
		return
	
	_state._air_drift_state = _state.not_air_drifting
	_state.current_speed *= .85
	
	_state.velocity = _state.calculate_velocity(0, delta)
	pass

func reset():
	if _player.anim_tree != null:
		_player.anim_tree.travel("Skid")
	_state.velocity.y = 0
	_state.move_direction = -(_state.camera_relative_movement)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
