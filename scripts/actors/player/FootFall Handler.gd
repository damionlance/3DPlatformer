extends Node3D

@onready var _particles = preload("res://scenes/particles/FootstepParticles.tscn")

func fire_footstep():
	var new_particle = _particles.instantiate()
	add_child(new_particle)
	new_particle.global_position = $"Footstep Particles".global_position
	for body in $"Footstep Particles".get_overlapping_bodies():
		if body.get_parent() is MeshInstance3D:
			var floor_material = body.get_parent().mesh["surface_0/material"]
			break
