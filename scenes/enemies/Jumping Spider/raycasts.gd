extends Node3D

signal stop_moving

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not $"%Left Raycast".is_colliding() or not $"%Right Raycast".is_colliding():
		emit_signal("stop_moving")
