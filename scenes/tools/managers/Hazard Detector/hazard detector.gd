extends Area3D

@export var hazard_physics_layer := 64

# Called when the node enters the scene tree for the first time.
func _ready():
	collision_mask = hazard_physics_layer
	if get_parent() is CharacterBody3D:
		if get_parent().has_method("hazard_reaction"):
			connect("area_entered", get_parent().hazard_reaction)
