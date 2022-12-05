extends Node

class_name FloorSlide


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "FloorSlide"
var _keys

#onready variables
onready var _state = get_parent()
onready var _player = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_state.state_dictionary[_state_name] = self
	_state.update_state(_state_name)
	pass # Replace with function body.

func update(_delta):
	_player.anim_tree.travel("Floor Skid")
	#player.animation_player.play("Idle")
	_state._air_drift_state = _state.not_air_drifting
	#_state.current_speed *= _state.floor_fricion * 2
	
	if _state.velocity.length() < .01:
		_state.update_state("Idle")
		_state.attempting_pivot = false
		return
	
	if not _player.is_on_floor():
		_state.update_state("Falling")
		return
	else:
		_state.current_speed = 0
		_state.velocity = Vector3.ZERO
	if  _state._jump_state == _state.jump_pressed:
		print("DO A SIDE FLIP")
		return
	pass

func reset():
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
