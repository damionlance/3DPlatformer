extends Area3D

var lock := false
var player_camera
# Called when the node enters the scene tree for the first time.
func _ready():
	player_camera = get_tree().get_current_scene().find_child("Player").find_child("CameraPivot")

func _process(_delta):
	if lock:
		player_camera.look_at(player_camera.global_position + $"RayCast3D".target_position)

func _on_body_entered(body):
	if body.name == "Player":
		lock = true


func _on_body_exited(body):
	if body.name == "Player":
		lock = false
