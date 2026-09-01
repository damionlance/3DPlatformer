@tool
extends EditorScenePostImport

var root : Node = null

var functions : Dictionary = {
	"import_bouncy" : make_bouncy,
}

func _post_import(scene: Node) -> Object:
	root = scene
	iterate(scene)
	if root is Node3D:
		root.transform = Transform3D.IDENTITY
	return root

func iterate(node : Node) -> void:
	if node == null: return
	var meta : Dictionary = read_metadata(node)
	
	if not meta.is_empty():
		for key in meta.keys():
			functions[key].call()
	
	for child in node.get_children():
		iterate(child)
	pass

func read_metadata(object : Object) -> Dictionary:
	if not object.has_meta(&"extras"):
		return {}
	
	return object.get_meta(&"extras")

func make_bouncy(object : Object) -> void:
	
	pass
