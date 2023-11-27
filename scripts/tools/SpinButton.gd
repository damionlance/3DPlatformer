extends Area3D

signal spinning

func _process(delta):
	for body in get_overlapping_bodies():
		if body.name == "Player":
			if body.state._currentstate.state_name == "Floor Spin":
				emit_signal("spinning", true)
				body.global_position = $PlayerPositionLock.global_position
				rotation = body.rotation
				return
	emit_signal("spinning", false)
