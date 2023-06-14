@tool
extends Node3D

var tween : Tween
var localHeight
@export var spinHeight : Vector3
@export var risingSpeed : float
@export var fallingSpeed : float
@export var mesh : MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready():
	if Engine.is_editor_hint():
		global_position = mesh.global_position
	else:
		mesh.global_position = global_position
		localHeight = global_position

func _update_localHeight(valueToUpdate):
	localHeight += valueToUpdate

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
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
