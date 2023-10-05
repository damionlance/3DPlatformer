extends Node

#Instantiate particle scenes
var footstepParticles = preload("res://scenes/particles/FootstepParticles.tscn")

@export var footstep := false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if footstep:
		var new_footstep = footstepParticles.instantiate()
		add_child(new_footstep)
		new_footstep.global_position = self.global_position
		footstep = false
	pass
