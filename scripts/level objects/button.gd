extends Area3D

class_name interactive_button

var properties = ["interactable"]
var activated := false
var _player

var inactive = false
signal add_body
signal remove_body
signal activate

var collected := false
var material
# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().get_current_scene() is Control:
		return
	await get_tree().get_current_scene().level_loaded
	material = $"../Button".get_active_material(0).duplicate()
	$"../Button".set_surface_override_material(0, material)
	_player = get_tree().current_scene.find_child("Player")
	for property in properties:
		add_to_group(property)
	if Global.WORLD_COLLECTIBLES.has(get_parent().name):
		collected = Global.WORLD_COLLECTIBLES[get_parent().name]
	
	if collected:
		emit_signal("activate")
		_activate()
	else:
		$"../Button".get_active_material(0).albedo_color = Color(255,0,0)
	
	
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _activate():
	$"../Button".get_active_material(0).albedo_color = Color(0,255,0)
	$"../AudioStreamPlayer3D".play()
	if collected:
		return
	emit_signal("activate")
	collected = true
	Global.UPDATE_COLLECTIBLES(get_parent().name, collected)
	activated = true

func _on_body_exited(body):
	if body.name == "Player":
		body.remove_body(self)
		inactive = false


func _on_body_entered(body):
	if body.name == "Player":
		body.add_body(self, "[img]res://assets/textures/input prompts/active input/Jump.png[/img]")
