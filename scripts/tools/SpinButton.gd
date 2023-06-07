extends Area3D

signal spinning
# Called when the node enters the scene tree for the first time.
func _process(delta):
	for body in get_overlapping_bodies():
		if body.name == "Player":
			if body._state._current_state._state_name == "Floor Spin":
				emit_signal("spinning", true)
				body.global_position = $PlayerPositionLock.global_position
				$MeshInstance3D.rotation = body.rotation
				return
	emit_signal("spinning", false)
