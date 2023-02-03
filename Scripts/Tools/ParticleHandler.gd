extends Node

#Instantiate particle scenes
var footstepParticles = preload("res://MiscScenes/ParticleEffects/FootstepParticles.tscn")

export var footstep := false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if footstep:
		var new_footstep = footstepParticles.instance()
		add_child(new_footstep)
		new_footstep.global_translation = self.global_translation
		footstep = false
	pass
