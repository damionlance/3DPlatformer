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
onready var state = get_parent()
onready var player = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	state.state_dictionary[_state_name] = self
	state.update_state(_state_name)
	pass # Replace with function body.

func update(delta):
	player.current_jump = 0
	player.player_anim.play("Idle0")
	state.is_jumping = false
	#player.animation_player.play("Idle")
	if state.InputDirection != Vector2.ZERO:
		state.update_state("Running")
		return
	else:
		state.current_speed = 0
	if state.attempting_jump:
		state.update_state("Jump")
		return
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
