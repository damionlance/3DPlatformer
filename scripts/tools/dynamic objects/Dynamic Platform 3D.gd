extends Node
class_name DynamicPlatform3D

@onready var object := $"%object"
@onready var mesh : Node = object.get_child(0) if object.get_child_count() != 0 else null

@export_category("Debug Properties")
## Set the size of the generated debug box.
@export var size := Vector2(4, 4)
@export_color_no_alpha var mesh_color := Color.BLACK
# Called when the node enters the scene tree for the first time.

func generate_collision_data() -> void:
	
	if mesh:
		for child : MeshInstance3D in mesh.get_children():
			child.reparent(object)
	var collision_shape := CollisionShape3D.new()
	collision_shape.name = "CollisionShape3D"
	
	object.add_child(collision_shape)
	collision_shape.make_convex_from_siblings()
