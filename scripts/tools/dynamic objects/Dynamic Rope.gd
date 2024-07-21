@tool
class_name DynamicRope extends Node3D

## Visual component of the rope. Must be Child of dynamic rope and set via export variable.
@export var mesh_instance : MeshInstance3D = null
## Sets the initial length and angle of the Rope.
@export var bottom_point : Node3D = null

@export var player_height := 2.0

var previous_bottom_point_position := Vector3.ZERO

func _get_configuration_warnings() -> PackedStringArray:
	var warning_array : Array[String] = []
	if mesh_instance == null:
		warning_array.append("Must initialize property 'Mesh Instance' with MeshInstance3D.")
	if bottom_point == null:
		warning_array.append("Must initialize property 'Bottom Point' with Node3D.")
	
	return warning_array

func update_length() -> void:
	if mesh_instance == null:
		return
	if bottom_point.position == previous_bottom_point_position:
		return
	
	previous_bottom_point_position = bottom_point.position
	
	var initial_vector = bottom_point.position.normalized()
	var cross = initial_vector.cross(Vector3.UP).normalized()
	var height = (bottom_point.position).length()
	
	
	mesh_instance.mesh.height = height
	mesh_instance.position = bottom_point.position * .5
	
	mesh_instance.look_at(mesh_instance.global_position + cross.cross(initial_vector))
	if find_child("Area3D", false) != null:
		$"Area3D/CollisionShape3D".shape.size.y = height
		$"Area3D".basis = mesh_instance.basis
		$"Area3D".position = mesh_instance.position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(_delta : float) -> void:
	if Engine.is_editor_hint():
		update_length()
