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

export var jump_height : float
export var jump_time_to_peak : float
export var jump_time_to_descent : float

onready var jump_velocity : float = (2.0 * jump_height) / jump_time_to_peak
onready var jump_gravity : float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
onready var fall_gravity : float = (-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)

export var MovementSpeed := 5.0
export var MaxSpeed := 20.0
export var GroundFriction := .8
export var AirFriction := 0.1
export var AirSpeed := 2.0
export var CoyoteTime := 10

export var rotation_speed := .1

var current_jump = 0
var current_speed = 0
var current_dir := Vector2(0,1)
var character_model_direction := Vector2.ZERO

# Player State Flags
var attempting_jump := false
var is_jumping := false
var allow_jump := false
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
var InputDirectionGlobal := Vector2.ZERO

#onready variables
onready var player = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	_charge = false
	motion_direction = Vector2(0,0)
	pass # Replace with function body.

func _process(delta):
	
	input_handling()
	if player.is_on_floor() and InputDirection.length()!= 0:
		character_model_direction = InputDirection
		player.Velocity = Vector3(InputDirection.x*current_speed, current_jump, InputDirection.y*current_speed)
		if !attempting_jump:
			allow_jump = true
		player.Velocity.y = 0
	else:
		player.Velocity = Vector3(character_model_direction.x * current_speed, current_jump, character_model_direction.y * current_speed)
	
	_current_state.update(delta)

func _unhandled_input(event):
	if event.is_pressed() and !event.is_echo():
		_input_just_happened = true
	elif !event.is_pressed():
		_input_just_happened = true

func input_handling():
	InputDirection = Vector2.ZERO
	
	# Direction Handling for Player Movement
	InputDirection = Input.get_vector("Left","Right", "Forward", "Backward")
	InputDirection = InputDirection.rotated(-player.spring_arm.rotation.y)
	attempting_jump = Input.is_action_pressed("Jump")

func update_state( new_state ):
	_current_state = state_dictionary[new_state]
