extends Area3D

@export var camera_nodepath : NodePath
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	get_node(camera_nodepath).current = true
