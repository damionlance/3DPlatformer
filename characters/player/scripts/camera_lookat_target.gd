extends Node3D
@export var player : Player
var max_distance : float = 2.0
var floor_position : float = 0.0

func _process(_delta: float) -> void:
	var target_position : Vector3 = player.global_position + (player.move_direction * max_distance)
	if not player.is_on_floor():
		target_position.y = floor_position
	else:
		floor_position = target_position.y
	
	target_position.y += 3
	global_position = target_position
