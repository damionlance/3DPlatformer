class_name Windmill extends Node3D

##Rotation speed in radians per second
@export var speed : float = 0.1

@export_category("Required Nodes")
@export var pivot_point : Node3D
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta : float) -> void:
	pivot_point.rotate_x(speed * delta)
