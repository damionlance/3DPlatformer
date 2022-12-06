extends Node

class_name Idle


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#public variables
var cancellable = true
var breaks_momentum = false
var motion_input : String

#private variables
var _state_name = "Idle"
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
	_player.particles.emitting = false
	_player.anim_tree.travel("Idle1")
	#player.animation_player.play("Idle")
	_state._air_drift_state = _state.not_air_drifting
	
	_state.current_speed *= _state.floor_fricion
	
	if not _player.is_on_floor():
		_state.update_state("Falling")
	if _state.input_direction:
		_state.update_state("Running")
		return
	else:
		_state.current_speed = 0
		_state.velocity = Vector3.ZERO
	if  _state._jump_state == _state.jump_pressed:
		if _state.just_landed:
			_state.update_state("Jump2")
		else:
			_state.update_state("Jump")
		return
	pass

func reset():
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
