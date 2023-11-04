@tool
extends EditorScenePostImport

var property_dictionary = Dictionary()

# Called when the node enters the scene tree for the first time.

func _post_import(scene):
	scene.set_script(load("res://scripts/level objects/level start/level object tracker.gd"))
	iterate(scene, scene)
	return scene

var root = null
func iterate(node, main_scene):
	if node != null:
		if "-fire" in node.name:
			node = set_up_fire(node, main_scene)
		if "-slidingplat" in node.name:
			set_up_sliding_platform(node, main_scene)
		if "-risingplat" in node.name:
			set_up_rising_platform(node, main_scene)
		if "-fallingplat" in node.name:
			set_up_falling_platform(node, main_scene)
		if "-spinbutton" in node.name:
			node = set_up_spin_button(node, main_scene)
		if "-stompbutton" in node.name:
			set_up_stomp_button(node, main_scene)
		if "-risingdoor" in node.name:
			node = set_up_rising_door(node, main_scene)
		if "-passthru" in node.name:
			set_up_passthru_walls(node, main_scene)
		if "-coin" in node.name:
			set_up_coin(node, main_scene)
		if "-levelcoin" in node.name:
			set_up_level_coin(node, main_scene)
		if "-climbable" in node.name:
			set_up_climable_surface(node, main_scene)
		if "-hazard" in node.name:
			node = set_up_hazard(node, main_scene)
		for child in node.get_children():
			iterate(child, main_scene)

func set_up_hazard(node, main_scene) -> Node:
	node.create_convex_collision()
	node.set_script(load("res://scripts/tools/hazard.gd"))
	return node

func set_up_fire(fire, main_scene) -> Node:
	var new_fire = load("res://scenes/tools/lights/fire.tscn")
	new_fire = new_fire.instantiate()
	fire.add_child(new_fire)
	new_fire.set_owner(main_scene)
	return fire

func set_up_sliding_platform(platform, main_scene) -> Node:
	var mesh = main_scene.find_child(platform.name.trim_suffix("-slidingplat") + "-path")
	mesh.hide()
	if mesh:
		
		platform.set_script(load("res://scripts/tools/Moving Platform.gd"))
		platform.get_child(0).collision_layer = 4
		platform.path_positions.clear()
		var vertex_array = mesh.mesh._surfaces[Mesh.ARRAY_VERTEX]["vertex_data"].to_float32_array()
		var new_vert : Array[float]
		for i in 6:
			new_vert.append(vertex_array[i])
			if (i + 1)%3 == 0:
				platform.path_positions.append(Vector3(new_vert[0],new_vert[1],new_vert[2]) + mesh.position)
				new_vert.clear()
	return platform

func set_up_rising_platform(platform, main_scene):
	platform.set_script(load("res://scripts/level objects/spinplat.gd"))
	platform.initial_position = platform.position
	

func set_up_falling_platform(node, main_scene):
	var new_plat = load("res://scenes/tools/Dynamic Objects/UnstablePlatform.tscn").instantiate()
	node.get_parent().add_child(new_plat)
	new_plat.position = node.position
	new_plat.collision_layer = 4
	new_plat.set_owner(main_scene)
	new_plat.name = "UnstablePlatform-fallingplat"
	node.reparent(new_plat)
	node.name = "Mesh"
	if node.find_child("StaticBody3D") != null:
		node.find_child("StaticBody3D").find_child("CollisionShape3D").reparent(node.get_parent())

func set_up_passthru_walls(node, main_scene):
	node.create_trimesh_collision()
	node.get_child(0).set_collision_layer(8)

func set_up_coin(node, main_scene):
	var new_coin = load("res://scenes/Collectables/Coin.tscn").instantiate()
	node.get_parent().add_child(new_coin)
	new_coin.set_owner(main_scene)
	new_coin.name = "TempleCoin"
	new_coin.position = node.position + Vector3.UP
	main_scene.coins += 1
	node.hide()

func set_up_level_coin(node, main_scene):
	var new_coin = load("res://scenes/Collectables/Coin.tscn").instantiate()
	node.get_parent().add_child(new_coin)
	new_coin.set_owner(main_scene)
	new_coin.name = "TempleLevelCoin"
	new_coin.position = node.position + Vector3.UP
	main_scene.level_coins += 1
	node.hide()

func set_up_spin_button(button, main_scene) -> Node:
	var spin_button = load("res://scenes/tools/Interactive Objects/spin_button.tscn").instantiate()
	button.add_child(spin_button)
	spin_button.set_owner(main_scene)
	spin_button.get_child("CollisionShape3D")
	spin_button.position = button.position + Vector3.UP
	return button

func set_up_stomp_button(button, main_scene):
	var stomp_button = load("res://scenes/tools/Interactive Objects/stomp_button.tscn").instantiate()
	button.add_child(stomp_button)
	stomp_button.set_owner(main_scene)
	stomp_button.find_child("CollisionShape3D").set_shape(button.mesh)
	stomp_button.position = Vector3.UP
	
func set_up_rising_door(door, main_scene) -> Node:
	door.set_script(load("res://scripts/level objects/door.gd"))
	return door

func set_up_climable_surface(plane, main_scene) -> Node:
	plane.set_script(load("res://scripts/tools/climbable_zone.gd"))
	return plane
	
func set_up_leaf_emitter(leaf, main_scene) -> Node:
	var new_leaf = load("res://scenes/particles/ambientLeafParticles.tscn")
	new_leaf = new_leaf.instantiate()
	leaf.add_child(new_leaf)
	new_leaf.set_owner(main_scene)
	return leaf
