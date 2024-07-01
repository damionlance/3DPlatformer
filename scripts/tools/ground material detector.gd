extends RayCast3D

var material_tag : String = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_colliding():
		step()
		return
		var collider = get_collider().get_parent()
		if collider is MeshInstance3D:
			material_tag = collider.get_active_material(0).get_meta("sound", "default")

# Key: Mesh (don't need to worry about managing lifecycle)
# Value: Mesh Data Tools
var mesh_data = {}

func step():
	var mesh = get_mesh_using_raycast()
	if !mesh:
		return

	var material = get_ground_material_at_point_using_mesh_data_tool(mesh, global_position + Vector3.UP)
	if material:
		material_tag = material.get_meta("sound", "default")
	else:
		material_tag = "default"


func get_mesh_using_raycast() -> MeshInstance3D:
	var space_state = get_world_3d().direct_space_state

	var collider = get_collider().get_parent()
	if collider is CharacterBody3D:
		for child in collider.get_children():
			if child is MeshInstance3D:
				return child
	
	if collider is MeshInstance3D:
		return collider
	else:
		return null


func get_ground_material_at_point_using_mesh_data_tool(mesh_instance : MeshInstance3D, point : Vector3) -> Material:
	var start_time = Time.get_ticks_msec()

	# Create Mesh Data Tools From Mesh
	if !mesh_data.has(mesh_instance.mesh):
		_create_mesh_data_tools(mesh_instance.mesh)

	var mesh_data_tools = mesh_data[mesh_instance.mesh]
	for _mesh_data_tool in mesh_data_tools:

		var mesh_data_tool = _mesh_data_tool as MeshDataTool
		for face_index in mesh_data_tool.get_face_count():

			# If face is not facing up, we know this isn't a ground face
			# So just skip it
			if mesh_data_tool.get_face_normal(face_index).dot(Vector3.UP) <= 0:
				continue

			var v1_index := mesh_data_tool.get_face_vertex(face_index, 0)
			var v2_index := mesh_data_tool.get_face_vertex(face_index, 1)
			var v3_index := mesh_data_tool.get_face_vertex(face_index, 2)

			var v1_pos := mesh_instance.to_global(mesh_data_tool.get_vertex(v1_index))
			var v2_pos := mesh_instance.to_global(mesh_data_tool.get_vertex(v2_index))
			var v3_pos := mesh_instance.to_global(mesh_data_tool.get_vertex(v3_index))

			# If all vertices are above the point, this surface
			# is above the player so can't be hit
			if v1_pos.y > point.y and v2_pos.y > point.y and v3_pos.y < point.y:
				continue

			var collide = Geometry3D.ray_intersects_triangle(point, Vector3.DOWN, v1_pos, v2_pos, v3_pos)
			if collide:
				var material = mesh_data_tool.get_material()
				var end_time = Time.get_ticks_msec()
				var elapsed = end_time - start_time
				return material

	var end_time = Time.get_ticks_msec()
	var elapsed = end_time - start_time
	return null


# Could be preloaded in any number of ways
# For this example, just trigger it the first time a player tries to
# query a given mesh
func _create_mesh_data_tools(mesh: Mesh):
	var start_time = Time.get_ticks_msec()

	var mesh_data_tools : Array[MeshDataTool] = []
	for surface_index in mesh.get_surface_count():
		var mesh_data_tool = MeshDataTool.new()
		mesh_data_tool.create_from_surface(mesh, surface_index)
		mesh_data_tools.append(mesh_data_tool)

	mesh_data[mesh] = mesh_data_tools

	var end_time = Time.get_ticks_msec()
	var elapsed = end_time - start_time
