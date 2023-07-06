extends Area3D

@export var camera_direction : Vector3

var lock := false
var player_camera
# Called when the node enters the scene tree for the first time.
func _ready():
	player_camera = get_tree().get_current_scene().find_child("Player").find_child("CameraPivot")
	camera_direction.x = deg_to_rad(camera_direction.x)
	camera_direction.y = deg_to_rad(camera_direction.y)
	camera_direction.z = deg_to_rad(camera_direction.z)

func _process(_delta):
	if lock:
		player_camera.rotation = camera_direction

func _on_body_entered(body):
	if body.name == "Player":
		lock = true


func _on_body_exited(body):
	if body.name == "Player":
		lock = false
