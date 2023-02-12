extends Area3D

@export var requiredSpeed := 0.0

signal velocity_trigger_fired(body)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func _process(_delta):
	for body in get_overlapping_bodies():
		if body is CharacterBody3D:
			if body.velocity.length() >= requiredSpeed:
				emit_signal("velocity_trigger_fired",body)
		if body is RigidBody3D:
			if body.linear_velocity.length() >= requiredSpeed:
				emit_signal("velocity_trigger_fired",body)
