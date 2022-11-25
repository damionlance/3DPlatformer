extends Spatial

export var camera_sensitivity : Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	rotation_degrees.y -= Input.get_axis("CameraRight", "CameraLeft") * camera_sensitivity.y
	rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
	rotation_degrees.x -= Input.get_axis("CameraDown", "CameraUp") * camera_sensitivity.x
	rotation_degrees.x = clamp(rotation_degrees.x, -80.0, 30.0)
	pass
