tool
extends Node

export var radius := 1.0 setget editor_update
onready var visualization = $Visualization
onready var handle = $Handle

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.editor_hint:
		visualization.visible = false
	else:
		visualization.visible = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.editor_hint:
		handle.global_translation.y = get_parent().global_translation.y
		radius = (get_parent().global_translation - handle.global_translation).length()
		visualization.outer_radius = radius
		visualization.inner_radius = radius - .1

func editor_update(new_radius):
	radius = new_radius
	var vector = (handle.global_translation - get_parent().global_translation)
	handle.global_translation = vector.normalized() * radius
	
	visualization.outer_radius = radius
	visualization.inner_radius = radius - .1
