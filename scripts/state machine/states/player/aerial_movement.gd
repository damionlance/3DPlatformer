extends Node

class_name AerialMovement

#warning-ignore:unused_private_class_variable
var backwardsLedgeGrab := false
var airdrifting := false

var aerial_acceleration := 1
var delta_v
var entering_jump_angle

var constants := preload("res://resources/player/aerial physics constants.tres")

@onready var player = find_parent("Player")
@onready var animation_tree = player.find_child("AnimationTree")
@onready var state = find_parent("StateMachine")
@onready var controller = player.find_child("Controller", false)
@onready var raycasts = player.find_child("RaycastHandler", false)

# Helper Functions
func regular_aerial_movement_processing() -> Vector3:
	delta_v = Vector3.ZERO
	
	delta_v = controller.camera_relative_movement * controller.input_strength * aerial_acceleration
	delta_v = delta_v - player.horizontal_velocity.normalized() * delta_v.dot(player.horizontal_velocity.normalized())
	return delta_v
