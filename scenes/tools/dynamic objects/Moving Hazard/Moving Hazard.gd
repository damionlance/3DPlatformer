class_name MovingHazard3D
extends MovingObject3D

## If an object destroys itself on contact, play an animation
@export var destroys_self_on_contact : bool = false
@export var damage_launch_direction : Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
