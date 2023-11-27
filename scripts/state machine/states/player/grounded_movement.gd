extends Node

class_name GroundedMovement

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Floor Physics Constants
@export var floor_acceleration := 1.8

@onready var player = find_parent("Player")
@onready var state = find_parent("StateMachine")
@onready var controller = player.find_child("Controller", false)
@onready var raycasts := player.find_child("RaycastHandler", false)

func grounded_movement_processing() -> Vector3:
	#Reset vertical wall jump tech limit
	var delta_v
	
	delta_v = controller.camera_relative_movement * floor_acceleration
	
	return delta_v
