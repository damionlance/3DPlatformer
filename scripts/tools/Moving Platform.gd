@tool
extends Node3D
class_name moving_platform

@export var speed : float = 5.0
@export var delay_at_points : float = 0.0
@export var position_in_path : int = 0
var loop : bool = true
var forwards : bool = true
var tween
@export var button : NodePath

@export var path_positions : Array[Vector3]
@onready var collider = $StaticBody3D

var lines : Array[MeshInstance3D]

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.is_editor_hint():
		if button == NodePath(""):
			var direction = (path_positions[position_in_path] - global_position)
			var distance = direction.length()
			direction = direction.normalized()
			collider.constant_linear_velocity = direction*speed
			var time = (distance/speed)
			tween = create_tween().bind_node(self)
			tween.connect("finished", tween_finished)
			tween.tween_property(self, "global_position", path_positions[position_in_path], time).set_delay(delay_at_points)
		else:
			get_node(button).activate.connect(_on_stomp_button_velocity_trigger_fired)
	else:
		var direction = (path_positions[position_in_path] - global_position)
		var distance = direction.length()
		direction = direction.normalized()
		collider.constant_linear_velocity = direction*speed
		var time = (distance/speed)
		tween = create_tween().bind_node(self)
		tween.connect("finished", tween_finished)
		tween.tween_property(self, "global_position", path_positions[position_in_path], time).set_delay(delay_at_points)

func tween_finished():
	if tween != null and tween.is_running():
		tween.stop()
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
	collider.constant_linear_velocity = direction*speed
	var time = (distance/speed)
	tween = create_tween().bind_node(self)
	tween.connect("finished", tween_finished)
	tween.tween_property(self, "global_position", path_positions[position_in_path], time).set_delay(delay_at_points)


func _on_stomp_button_velocity_trigger_fired(_body):
	var direction = (path_positions[position_in_path] - global_position)
	var distance = direction.length()
	direction = direction.normalized()
	collider.constant_linear_velocity = direction*speed
	var time = (distance/speed)
	tween = create_tween().bind_node(self)
	tween.connect("finished", tween_finished)
	tween.tween_property(self, "global_position", path_positions[position_in_path], time).set_delay(delay_at_points)

