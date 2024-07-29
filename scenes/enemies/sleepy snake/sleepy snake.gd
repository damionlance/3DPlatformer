extends CharacterBody3D

@onready var state_chart = $"StateChart"
@onready var neck_mesh = $"body/game_rig"

var target : CharacterBody3D = null

func _physics_process(delta: float) -> void:
	pass

func face_target(_delta : float = 0.0) -> void:
	if target == null:
		return
	
	var target_rotation = target.global_position - global_position
	var target_angle = atan2(target_rotation.x, target_rotation.z)
	neck_mesh.rotation.y = lerpf(neck_mesh.rotation.y, target_angle, .3)

func idle(_delta : float = 0.0) -> void:
	await get_tree().create_timer(5).timeout
	state_chart.send_event("Attack")

func return_to_idle() -> void:
	state_chart.send_event("Idle")

func _on_player_detection_body_entered(body: Node3D) -> void:
	state_chart.send_event("Wake Up")
	target = body

func _on_player_detection_body_exited(body: Node3D) -> void:
	target = null
	state_chart.send_event("Sleep")
