extends MeshInstance3D

func _ready():
	create_convex_collision()
	add_to_group("climbable zone")
	get_child(0).set_collision_layer(64)
	
