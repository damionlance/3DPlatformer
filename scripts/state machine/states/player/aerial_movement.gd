extends Node

class_name AerialMovement

#warning-ignore:unused_private_class_variable
var backwardsLedgeGrab := false
var airdrifting := false

var entering_jump_angle

var constants := preload("res://resources/player/aerial physics constants.tres")

@onready var player = find_parent("Player")
@onready var state = find_parent("StateMachine")
@onready var controller = player.find_child("Controller", false)
@onready var raycasts = player.find_child("RaycastHandler", false)

# Helper Functions
