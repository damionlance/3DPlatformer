extends RayCast


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	pass # Replace with function body.

func _process(delta):
	cast_to = get_parent().velocity
	translation = get_parent().translation
	translation.y += 2
