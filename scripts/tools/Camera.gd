extends Node3D

@export var camera_sensitivity := Vector2(0,0)
@onready var player := get_parent()
@onready var camera := $"SpringArm3D/Camera3D"
@onready var raycasts := $"../Raycast Handler"

@export var change_in_fov = 7.5
@export var base_fov = 80.0

var previous_camera_height = 0
var camera_tracking_position = Vector3.ZERO

var chase_cam = true

var halt_input := false

var match_height
var tracking = false

var target_body

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	pass # Replace with function body.

func _physics_process(_delta):
	
	var spacestate = get_world_3d().direct_space_state
	
	var horizontal_speed = Vector3(player.velocity.x, 0, player.velocity.z).length()
	if horizontal_speed > 6:
		camera.fov = lerp(camera.fov, base_fov + (change_in_fov * (horizontal_speed/12)), .05)
	else:
		camera.fov = lerp(camera.fov, base_fov, .05)
	var parent_position = player.global_position + (Vector3.UP * 4)
	
	var height_difference = previous_camera_height - parent_position.y
	var camera_horizontal_distance = Vector3(camera_tracking_position.x, 0, camera_tracking_position.z)
	camera_horizontal_distance -= Vector3(parent_position.x, 0, parent_position.z)
	
	rotation_degrees.x -= Input.get_axis("CameraDown", "CameraUp") * Global.settings["Look Sensitivity"]
	rotation_degrees.x = clamp(rotation_degrees.x, -80.0, 30.0)
	rotation_degrees.y -= Input.get_axis("CameraRight", "CameraLeft") * Global.settings["Look Sensitivity"]
	rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)
	
	if Input.is_action_just_pressed("Camera Mode"): chase_cam = bool(1 - int(chase_cam))
	if Input.is_action_just_pressed("Reset Camera"):
		rotation = Vector3.ZERO
		rotation.y = player.rotation.y
	if chase_cam:
		if camera_horizontal_distance.length() != 0:
			var p1 = camera_tracking_position - camera.global_position
			var p2 = parent_position - camera.global_position
			var angle = atan2(p1.x, p1.z) - atan2(p2.x, p2.z)
			
			#rotation_degrees.y -= rad_to_deg(angle)
	
	if not halt_input:
		position = player.global_position
		
	
	pass

func set_target_body(body):
	target_body = body
