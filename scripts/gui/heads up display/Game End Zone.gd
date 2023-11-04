extends Area3D


func _on_body_entered(body):
	if body.name == "Player":
		set_deferred("monitoring", false)
