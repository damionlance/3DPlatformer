extends Area3D

signal collided_with_body(path_follow : PathFollow3D)

var launch_direction := Vector3.ZERO

var collide := false

func _ready() -> void:
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	if get_parent().get_parent().get_parent().has_method("hazard_collided"):
		connect("collided_with_body", get_parent().get_parent().get_parent().hazard_collided)
		get_parent().get_parent().get_parent().starts_in_object
	if "launch_direction" in get_parent().get_parent().get_parent():
		launch_direction = get_parent().get_parent().get_parent().launch_direction

func _on_body_exited(body: Node3D) -> void:
	collide = true

func _on_body_entered(body: Node3D) -> void:
	if get_parent().get_parent().get_parent().starts_in_object:
		if collide:
			print("Collided")
			emit_signal("collided_with_body", get_parent())
			collide = false
	else:
		emit_signal("collided_with_body", get_parent())
