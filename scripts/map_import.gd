@tool
extends EditorScenePostImport

var property_dictionary = Dictionary()

# Called when the node enters the scene tree for the first time.
var main_scene
func _post_import(scene):
	main_scene = scene
	iterate(scene)
	return scene
var root = null
func iterate(node):
	if node != null:
		if "-fire" in node.name:
			node = set_up_fire(node)
		if "-slidingplat" in node.name:
			set_up_sliding_platform(node)
		if "-risingplat" in node.name:
			set_up_rising_platform(node)
		if "-spinbutton" in node.name:
			node = set_up_spin_button(node)
		if "-risingdoor" in node.name:
			node = set_up_rising_door(node)
		for child in node.get_children():
			iterate(child)

func set_up_fire(fire) -> Node:
	var new_fire = load("res://scenes/tools/lights/fire.tscn")
	new_fire = new_fire.instantiate()
	fire.add_child(new_fire)
	new_fire.set_owner(main_scene)
	return fire

func set_up_sliding_platform(platform) -> Node:
	var mesh = main_scene.find_child(platform.name.trim_suffix("-slidingplat") + "-path")
	if mesh:
		
		platform.set_script(load("res://scripts/tools/Moving Platform.gd"))
		platform.path_positions.clear()
		var vertex_array = mesh.mesh._surfaces[Mesh.ARRAY_VERTEX]["vertex_data"].to_float32_array()
		var new_vert : Array[float]
		for i in 6:
			new_vert.append(vertex_array[i])
			if (i + 1)%3 == 0:
				platform.path_positions.append(Vector3(new_vert[0],new_vert[1],new_vert[2]) + mesh.position)
				new_vert.clear()
	return platform

func set_up_rising_platform(platform):
	platform.set_script(load("res://scripts/level objects/spinplat.gd"))
	platform.initial_position = platform.position
	

func set_up_spin_button(button) -> Node:
	var spin_button = load("res://scenes/tools/Interactive Objects/spin_button.tscn").instantiate()
	button.add_child(spin_button)
	spin_button.set_owner(main_scene)
	spin_button.get_child("CollisionShape3D").set_shape(button.mesh)
	spin_button.position = button.position + Vector3.UP
	return button

func set_up_rising_door(door) -> Node:
	door.set_script(load("res://scripts/level objects/door.gd"))
	return door