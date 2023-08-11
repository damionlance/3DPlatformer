@tool
extends Node3D

var tween : Tween
@export var button : NodePath
@export var initial_position : Vector3
@export var spinHeight : Vector3
@export var risingSpeed : float
@export var fallingSpeed : float

func _ready():
	global_position = initial_position
	await get_node(button).ready
	get_node(button).activate.connect(_on_stomp_button_velocity_trigger_fired)
	
	var size
	

func _process(_delta):
	if Engine.is_editor_hint():
		global_position = initial_position + spinHeight

func _on_spin_button_spinning(isSpin):
	if tween != null and tween.is_running():
		tween.stop()
	tween = create_tween()
	var distance
	if isSpin:
		distance = (global_position - (initial_position + spinHeight)).length()
		tween.tween_property(self, "global_position", initial_position + spinHeight, distance/risingSpeed)
	else:
		distance = (global_position - initial_position).length()
		tween.tween_property(self, "global_position", initial_position, distance/fallingSpeed)


func _on_stomp_button_velocity_trigger_fired(_body):
	if tween != null and tween.is_running():
		tween.stop()
	tween = create_tween()
	var distance = (global_position - (initial_position + spinHeight)).length()
	tween.tween_property(self, "global_position", initial_position + spinHeight, distance/risingSpeed)
	get_child(0).constant_linear_velocity = Vector3.UP * risingSpeed
	await tween.finished
	tween = create_tween()
	var downDistance = (global_position - initial_position).length()
	tween.tween_property(self, "global_position", initial_position, downDistance/fallingSpeed)
	get_child(0).constant_linear_velocity = Vector3.DOWN * fallingSpeed
