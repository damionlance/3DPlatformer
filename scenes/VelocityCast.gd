extends RayCast3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	pass # Replace with function body.

func _process(delta):
	target_position = get_parent().velocity
	position = get_parent().position
	position.y += 2
