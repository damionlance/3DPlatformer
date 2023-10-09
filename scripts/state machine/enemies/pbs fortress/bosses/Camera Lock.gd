extends Node3D

@onready var player_camera = get_node("../Player/CameraPivot")
@onready var player = get_node("../Player")
var player_cam_original_position
var player_cam_original_length
@onready var base_position = position
var active := false

func _ready():
	activate()

func _process(delta):
	if active:
		var distance = player.global_position - base_position
		if distance.length() > 10:
			player_camera.global_position = global_position + (distance.normalized()*(distance.length()-10))
		elif distance.length() > 5:
			player_camera.global_position = global_position
		else:
			player_camera.global_position = global_position - (distance.normalized()*(distance.length()-10))
			pass
		player_camera.rotation.x = deg_to_rad(-30.0)

func activate():
	active = true
	player_cam_original_position = player_camera.position
	player_cam_original_length = player_camera.get_child(0).spring_length
	player_camera.get_child(0).spring_length = 15
	pass

func deactivate():
	active = false
	player_camera.position = player_cam_original_position
	player_camera.get_child(0).spring_length = player_cam_original_length
	pass


func _on_damaged_dead():
	deactivate()
	pass # Replace with function body.
