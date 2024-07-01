extends Area3D

@export var hazard_physics_layer := 64
@export var death_planes_layer := 16
var hazard_collided_with : Hazard3D

# Called when the node enters the scene tree for the first time.
func _ready():
	collision_mask = hazard_physics_layer
	if get_parent() is CharacterBody3D:
		if get_parent().has_method("hazard_reaction"):
			connect("area_entered", get_parent().hazard_reaction)

func disable() -> void:
	collision_mask = death_planes_layer

func enable() -> void:
	collision_mask = death_planes_layer + hazard_physics_layer
