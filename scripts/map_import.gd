@tool
extends EditorScenePostImport

# Called when the node enters the scene tree for the first time.
var main_scene
func _post_import(scene):
	main_scene = scene
	iterate(scene)
	return scene

func iterate(node):
	if node != null:
		
		if "-fire" in node.name:
			node = set_up_fire(node)
		for child in node.get_children():
			iterate(child)

func set_up_fire(fire) -> Node:
	var new_fire = load("res://scenes/tools/lights/fire.tscn")
	new_fire = new_fire.instantiate()
	fire.get_parent().add_child(new_fire)
	new_fire.set_owner(main_scene)
	fire.queue_free()
	return fire
