extends Camera3D
@export var move_direction : Vector3
@export var rotate_direction : Vector3
@export var speed := 1.0
@export var rotation_speed := 1.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current == true:
		global_position += move_direction * speed * delta
		rotation += rotate_direction* deg_to_rad(rotation_speed) * delta
