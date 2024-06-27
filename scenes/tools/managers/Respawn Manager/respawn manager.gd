extends Node3D

signal respawn(respawn_position : Vector3)

func _ready():
	if get_parent() is CharacterBody3D:
		if get_parent().has_method("respawn"):
			connect("respawn", get_parent().respawn)

func process_respawn():
	if $"Respawn Zone Detector".get_overlapping_areas().size() == 1:
		_linear_respawn_zone()
	else:
		_free_respawn_zone()

func _linear_respawn_zone():
	var last_respawn_position = $"Respawn Zone Detector".get_overlapping_areas()[0].active_checkpoint.global_position
	emit_signal("respawn", last_respawn_position)

func _free_respawn_zone():
	var nearest_position : Vector3
	
	for checkpoint in get_tree().get_nodes_in_group("checkpoint"):
		var new_checkpoint_distance = (checkpoint.global_position - global_position).length()
		var nearest_checkpoint_distance = (nearest_position - global_position).length()
		if nearest_position == null or new_checkpoint_distance < nearest_checkpoint_distance:
			nearest_position = checkpoint.global_position
	emit_signal("respawn", nearest_position)
