extends Node3D

@onready var _particles = preload("res://scenes/particles/FootstepParticles.tscn")

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func fire_footstep():
	var new_particle = _particles.instantiate()
	add_child(new_particle)
	new_particle.global_position = $"Footstep Particles".global_position
	print("def here")
	for body in $"Footstep Particles".get_overlapping_bodies():
		print("Has bodies")
		if body.get_parent() is MeshInstance3D:
			var floor_material = body.get_parent().mesh["surface_0/material"]
			new_particle.draw_pass_1.material = floor_material.duplicate()
			new_particle.draw_pass_1.material["shading_mode"] = 0
