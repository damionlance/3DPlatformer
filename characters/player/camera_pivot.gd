extends Node3D
@export var pcam : PhantomCamera3D
@export var player : Player
var target_position : Vector3 = Vector3.ZERO
var motion_offset_distance : float = 4.0
var previous_position : Vector3 = Vector3.ZERO
var sensitivity : float = 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	target_position = Vector3(player.global_position.x, global_position.y, player.global_position.z)
	if player.is_on_floor():
		target_position.y = player.global_position.y + 4
	global_position = global_position.lerp(target_position, 0.5)
	var camera_rotation = Input.get_vector("cam_left", "cam_right", "cam_down", "cam_up")
	var pcam_new_rotation = rotation + Vector3(camera_rotation.y, camera_rotation.x, 0) * delta
	var camera_horizontal_distance = Vector3(target_position.x, 0, target_position.z)
	
	if camera_horizontal_distance.length() != 0:
			var p1 = previous_position - pcam.global_position
			var p2 = global_position - pcam.global_position
			var angle = atan2(p1.x, p1.z) - atan2(p2.x, p2.z)
			
			pcam_new_rotation.y -= (angle)
	
	rotation.y = pcam_new_rotation.y
	
	previous_position = global_position
	
	pass
