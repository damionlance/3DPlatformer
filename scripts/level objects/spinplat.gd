@tool
extends Node3D

var tween : Tween
var localHeight
@export var spinHeight : Vector3
@export var risingSpeed : float
@export var fallingSpeed : float
@export var mesh : MeshInstance3D
@export var reset_position : bool = false

func _ready():
	if Engine.is_editor_hint():
		global_position = mesh.global_position
	else:
		mesh.global_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		if mesh == null:
			mesh = get_tree().get_edited_scene_root().get_child(4).find_child(name)
		if reset_position:
			global_position = mesh.global_position
		else:
			mesh.global_position = global_position + spinHeight


func _on_spin_button_spinning(isSpin):
	tween = create_tween()
	var distance
	if isSpin:
		distance = (mesh.global_position - (global_position + spinHeight)).length()
		tween.tween_property(mesh, "global_position", global_position + spinHeight, distance/risingSpeed)
	else:
		distance = (mesh.global_position - global_position).length()
		tween.tween_property(mesh, "global_position", global_position, distance/fallingSpeed)
