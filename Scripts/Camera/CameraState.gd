extends Node
# Base type for the camera rig's state classes. Contains boilerplate code to
# get autocompletion and type hints.

var camera_rig: CameraRig


func _ready() -> void:
	camera_rig = owner
