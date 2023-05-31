extends Area3D

func _ready():
	$MeshInstance3D.create_convex_collision()
	add_to_group("climbable zone")
