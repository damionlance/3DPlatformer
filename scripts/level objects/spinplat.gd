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
	#get_node(button).spinning.connect(_on_spin_button_spinning)

func _process(delta):
	if Engine.is_editor_hint():
		global_position = initial_position + spinHeight

func _on_spin_button_spinning(isSpin):
	tween = create_tween()
	var distance
	if isSpin:
		distance = (global_position - (initial_position + spinHeight)).length()
		tween.tween_property(self, "global_position", initial_position + spinHeight, distance/risingSpeed)
	else:
		distance = (global_position - initial_position).length()
		tween.tween_property(self, "global_position", initial_position, distance/fallingSpeed)
