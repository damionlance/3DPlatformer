extends Node

#constants

enum {
	JUST_PRESSED = 0,
	HELD = 1,
	JUST_RELEASED = 2,
	RELEASED = 3
}

#public variables
var state_dictionary : Dictionary
var motion_direction = Vector2(0.0,0.0)

#Player Physics Variables
var Gravity := Vector3(0.0, -200, 0.0)
export var MovementSpeed := 5
export var MaxSpeed := 20
export var GroundFriction := .8
export var JumpStrength := 10
export var AirSpeed := 2
export var CoyoteTime := 10

var current_jump = 0
var current_speed = 0
var current_dir := Vector2(0,1)

# Player State Flags
var attempting_jump := false
var is_jumping := false
var is_on_floor := false

#private variables
var _hold_frames : int = 5 #time to transition from a press to a hold
var _keys
var _motion_input_buffer : Array
var _motion_input_frame_reset : int = 7
var _motion_input_current_frame = 0
var _current_state
var _input_just_happened
var _execute_motion_input
var _charge

var InputDirection :=  Vector2.ZERO

#onready variables
onready var player = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	_charge = false
	motion_direction = Vector2(0,0)
	pass # Replace with function body.

func _process(delta):
	input_handling()
	_current_state.update(delta)
	player.Velocity = Vector3(current_dir.x*current_speed, current_jump, current_dir.y*current_speed)

func _unhandled_input(event):
	if event.is_pressed() and !event.is_echo():
		_input_just_happened = true
	elif !event.is_pressed():
		_input_just_happened = true

func input_handling():
	InputDirection = Vector2.ZERO
	
	# Direction Handling for Player Movement
	InputDirection = Input.get_vector("Right", "Left", "Forward", "Backward")
	InputDirection = InputDirection.rotated(player.spring_arm.rotation.y).normalized()
	
	if InputDirection.length() != 0:
		var x = InputDirection.angle()
		var y = current_dir.angle()
		var angle = atan2(sin((x-y)), cos((x-y)))
		var oldDir = current_dir
		current_dir.x = -(cos(angle) * oldDir.x - sin( angle) * oldDir.y)
		current_dir.y = (sin(angle) * oldDir.x + cos( angle) * oldDir.y)
	
	attempting_jump = Input.is_action_just_pressed("Jump")

func update_state( new_state ):
	_current_state = state_dictionary[new_state]
