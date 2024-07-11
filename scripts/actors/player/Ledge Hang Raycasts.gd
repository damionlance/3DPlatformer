extends Node3D

@onready var forward_raycasts = [$"Left Forward", $"Right Forward"]
@onready var downward_raycasts = [$"Left Downward", $"Right Downward"]

@onready var state_chart := $%StateChart

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	#Check if raycasts are both colliding
	var colliding := true
	for raycast in forward_raycasts:
		if not raycast.is_colliding():
			colliding = false
			break
	#Check if raycasts normals are within margin of error
	if not colliding:
		if downward_raycasts[0].is_colliding() and downward_raycasts[1].is_colliding():
			if downward_raycasts[0].get_collision_normal() == downward_raycasts[1].get_collision_normal():
				state_chart.send_event("ledge hang")

func get_average_wall_distance() -> Vector3:
	var distance := Vector3.ZERO
	if forward_raycasts[0].is_colliding():
		distance += forward_raycasts[0].get_collision_point() - forward_raycasts[0].global_position
	if forward_raycasts[1].is_colliding():
		distance += forward_raycasts[1].get_collision_point() - forward_raycasts[1].global_position
	return distance

func force_update() -> void:
	for raycast in forward_raycasts + downward_raycasts:
		raycast.force_raycast_update()

func get_average_wall_normal() -> Vector3:
	var sum := Vector3.ZERO
	if forward_raycasts[0].is_colliding():
		sum += forward_raycasts[0].get_collision_normal()
	if forward_raycasts[1].is_colliding():
		sum += forward_raycasts[1].get_collision_normal()
	
	return sum.normalized()
