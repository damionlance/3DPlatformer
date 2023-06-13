extends Area3D

@export var meshes : Array[NodePath]

func _ready():
	for mesh in meshes:
		get_node(mesh).create_convex_collision()
		get_node(mesh).add_to_group("climbable zone")
	
