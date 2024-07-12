extends MovingObject3D
class_name TriggerableMovingObject

## Allows the triggerable moving object to lock the player to the center of the Area3D.
@export var lock_player := true

@export var return_to_start := true

var _attached_body : CharacterBody3D = null

func extra_ready_processing() -> void:
	path_follow = $"Path3D/PathFollow3D"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _attached_body != null:
		if lock_player:
			if not Input.is_action_pressed("Jump"):
				_attached_body.state_chart.send_event("Fall")
				_attached_body = null
				return
			_attached_body.global_position = path_follow.global_position
		pass
	if return_to_start and $"%PathFollow3D".progress_ratio == 1.0 and $"%object".get_overlapping_bodies().size() == 0:
		_create_path_tween(path_follow, true)

func _on_object_body_entered(body: Node3D) -> void:
	if Input.is_action_pressed("Jump"):
		_attached_body = body
		if lock_player:
			body.state_chart.send_event("Rope Climb")
			_create_path_tween(path_follow, true)
