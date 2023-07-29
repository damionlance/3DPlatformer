extends Camera3D
@export var move_direction : Vector3
@export var speed := 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current == true:
		position += move_direction * speed
