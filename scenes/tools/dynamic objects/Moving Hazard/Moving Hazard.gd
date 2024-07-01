class_name Hazard3D
extends MovingObject3D

## If an object destroys itself on contact, play an animation
@export var destroys_self_on_contact : bool = false
@export var launch_direction : Vector3 = Vector3.ZERO
@export var starts_in_object : bool = false

var collide := false

func extra_ready_processing():
	for child in $PathFollow3D.get_children():
		child.collision_layer = 64
		child.collision_mask = 5

func hazard_collided(hazard : PathFollow3D):
	_stop_tween(hazard)
