extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

signal take_damage(position)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for body in get_overlapping_bodies():
		if "causes_damage" in body:
			if body.causes_damage:
				emit_signal("take_damage", body.global_position)
	pass
