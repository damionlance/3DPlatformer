extends Area3D

var properties = ["interactable"]
var activated := false

signal activate
# Called when the node enters the scene tree for the first time.
func _ready():
	for property in properties:
		add_to_group(property)
	$"../Button".get_active_material(0).set_shader_parameter("ColorParameter", Color(255,0,0))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _activate():
	print(get_parent().get_parent().name)
	$"../Button".get_active_material(0).set_shader_parameter("ColorParameter", Color(0,255,0))
	emit_signal("activate")
	activated = true
