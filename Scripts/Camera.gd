extends Spatial

export var camera_sensitivity := Vector2(0,0)
onready var _player := get_parent()
onready var _camera := $"SpringArm/Camera"

export var change_in_fov = 7.5
export var base_fov = 80

var manual_camera := false
var previous_camera_height = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var horizontal_speed = Vector3(_player.velocity.x, 0, _player.velocity.z).length()
	if horizontal_speed > 6:
		_camera.fov = lerp(_camera.fov, base_fov + (change_in_fov * (horizontal_speed/12)), .05)
	else:
		_camera.fov = lerp(_camera.fov, base_fov, .05)
	var _parent_position = _player.translation
	var camera_tracking_position = Vector3.ZERO
	var height_difference = abs(previous_camera_height - _parent_position.y)
	
	if not _player.is_on_floor() and height_difference < 6:
		camera_tracking_position = Vector3(_parent_position.x, previous_camera_height, _parent_position.z)
	else:
		previous_camera_height = _parent_position.y
		camera_tracking_position = _parent_position
	
	#process up and down, camera will not aim up and down at the player.
	rotation_degrees.x -= Input.get_axis("CameraDown", "CameraUp") * camera_sensitivity.x
	rotation_degrees.x = clamp(rotation_degrees.x, -80.0, 30.0)
	rotation_degrees.y -= Input.get_axis("CameraRight", "CameraLeft") * camera_sensitivity.y
	rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
	translation = lerp(translation, camera_tracking_position, .05)
	
	pass
