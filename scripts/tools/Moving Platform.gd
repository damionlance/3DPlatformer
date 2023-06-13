@tool

extends Node3D
class_name moving_platform

@export var mesh : MeshInstance3D
@export var platform_path : Array[Node3D]
@export var speed : float = 1.0
@export var delay_at_points : float = 0.0
@export var position_in_path : int = 0
var loop : bool = true
var forwards : bool = true
var tween
var path_positions : Array[Vector3]

@onready var platform_path_length : int = platform_path.size()

var lines : Array[MeshInstance3D]

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.is_editor_hint():
		mesh.reparent(self)
		for node in platform_path:
			add_child(node)
			node.set_owner(get_tree().get_root())
			node.set_as_top_level(true)
		tween = create_tween().bind_node(self,)
		tween.connect("finished", tween_finished)
		var direction = (platform_path[position_in_path].global_position - global_position)
		var distance = direction.length()
		direction = direction.normalized()
		var time = (distance/speed)
		mesh.get_child(0).constant_linear_velocity = direction * speed
		tween.tween_property(self, "global_position", platform_path[position_in_path].global_position, time).set_delay(delay_at_points)

func _process(delta):
	if Engine.is_editor_hint():
		editor_processes()
	else:
		pass

func editor_processes():
	if position_in_path > platform_path.size():
		position_in_path = 0
	if mesh != null:
		global_position = mesh.global_position
	if platform_path.size() != platform_path_length:
		setup_array()
	draw_lines()

func draw_lines():
	for line in lines:
		line.queue_free()
	lines.clear()
	for i in platform_path.size() - 1:
		lines.append(line(platform_path[i].global_position, platform_path[i+1].global_position))

func setup_array():
	if platform_path.size() > platform_path_length:
		platform_path[platform_path_length] = Node3D.new()
		add_child(platform_path[platform_path_length])
		platform_path[platform_path_length].set_owner(get_tree().get_edited_scene_root())
		platform_path[platform_path_length].name = "Point"
		platform_path_length = platform_path.size()
	else:
		for node in get_children():
			if node is Node3D:
				if !platform_path.has(node):
					node.queue_free()
	platform_path_length = platform_path.size()

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
		if position_in_path == platform_path.size():
			position_in_path = 0
	else:
		if forwards:
			position_in_path += 1
			if position_in_path == platform_path.size() - 1:
				forwards = false
		else:
			position_in_path -= 1
			if position_in_path == 0:
				forwards = true
	var direction = (platform_path[position_in_path].global_position - global_position)
	var distance = direction.length()
	direction = direction.normalized()
	var time = (distance/speed)
	mesh.get_child(0).constant_linear_velocity = direction * speed
	tween = create_tween()
	tween.connect("finished", tween_finished)
	tween.tween_property(self, "global_position", platform_path[position_in_path].global_position, time).set_delay(delay_at_points)
