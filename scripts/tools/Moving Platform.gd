@tool
extends Node3D
class_name moving_platform

@export var isOff = false

@export var speed : float = 5.0
@export var delay_at_points : float = 0.0
@export var position_in_path : int = 0
var loop : bool = true
var forwards : bool = true
var tween

@export var path_positions : Array[Vector3]
@onready var collider = $StaticBody3D

var lines : Array[MeshInstance3D]

# Called when the node enters the scene tree for the first time.
func _ready():
	if not isOff:
		if not Engine.is_editor_hint():
			tween = create_tween().bind_node(self)
			tween.connect("finished", tween_finished)
			var direction = (path_positions[position_in_path] - global_position)
			var distance = direction.length()
			direction = direction.normalized()
			collider.constant_linear_velocity = direction*speed
			var time = (distance/speed)
			tween.tween_property(self, "global_position", path_positions[position_in_path], time).set_delay(delay_at_points)

	

func line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	get_tree().get_root().add_child(mesh_instance)
	
	return mesh_instance

func tween_finished():
	if loop:
		position_in_path += 1
		if position_in_path == path_positions.size():
			position_in_path = 0
	else:
		if forwards:
			position_in_path += 1
			if position_in_path == path_positions.size() - 1:
				forwards = false
		else:
			position_in_path -= 1
			if position_in_path == 0:
				forwards = true
	var direction = (path_positions[position_in_path] - global_position)
	var distance = direction.length()
	direction = direction.normalized()
	var time = (distance/speed)
	collider.constant_linear_velocity = direction*speed
	tween = create_tween()
	tween.connect("finished", tween_finished)
	tween.tween_property(self, "global_position", path_positions[position_in_path], time).set_delay(delay_at_points)


func _on_stomp_button_velocity_trigger_fired(body):
	isOff = false
	tween = create_tween().bind_node(self)
	tween.connect("finished", tween_finished)
	var direction = (path_positions[position_in_path] - global_position)
	var distance = direction.length()
	direction = direction.normalized()
	collider.constant_linear_velocity = direction*speed
	var time = (distance/speed)
	tween.tween_property(self, "global_position", path_positions[position_in_path], time).set_delay(delay_at_points)

