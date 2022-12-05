extends AerialMovement

class_name SideFlip

var _state_name = "SideFlip"
func _ready():
	_state.state_dictionary[_state_name] = self
	_state.update_state(_state_name)

func update():
	
	pass

func reset():
	
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
