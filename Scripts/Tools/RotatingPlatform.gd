extends Node3D

@export var rotationpersec := 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func _process(delta):
	rotate(Vector3.UP, deg_to_rad(rotationpersec))
	pass
