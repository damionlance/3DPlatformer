extends Area3D

class_name interactive_button

var properties = ["interactable"]
var activated := false
var _player

var inactive = false
signal add_body
signal remove_body
signal activate
# Called when the node enters the scene tree for the first time.
func _ready():
	_player = get_tree().current_scene.find_child("Player")
	for property in properties:
		add_to_group(property)
	$"../Button".get_active_material(0).set_shader_parameter("ColorParameter", Color(255,0,0))
	
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	pass # Replace with function body.

func _activate():
	$"../Button".get_active_material(0).set_shader_parameter("ColorParameter", Color(0,255,0))
	emit_signal("activate")
	activated = true

func _on_body_exited(body):
	if body.name == "Player":
		body.remove_body(self)
		inactive = false


func _on_body_entered(body):
	if body.name == "Player":
		body.add_body(self, "[img]res://assets/textures/input prompts/active input/Jump.png[/img]")
