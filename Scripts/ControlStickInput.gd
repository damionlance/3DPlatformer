extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var inputs

func _draw():
	inputs = get_parent().get_parent().get_parent().pivot_buffer
	for i in inputs.size():
		draw_circle(-inputs[i]*20, 2, Color.yellow)
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	update()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
