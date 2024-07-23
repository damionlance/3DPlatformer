extends Node3D

@onready var forward_raycasts = [$"Left Forward", $"Right Forward"]
@onready var forward_climb_raycasts = [$"Climbable Left Forward", $"Climbable Right Forward"]

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
	if colliding:
		if check_wall_group():
			state_chart.send_event("Wall Climb")
		elif forward_raycasts[0].get_collision_normal() == forward_raycasts[1].get_collision_normal():
			state_chart.send_event("Wall Slide")

func check_wall_group() -> bool:
	var in_group := false
	if forward_climb_raycasts[0].is_colliding():
		in_group = true
	else: return false
	if forward_climb_raycasts[1].is_colliding():
		if in_group:
			return true
	return false

func get_average_wall_distance() -> Vector3:
	var distance := Vector3.ZERO
	if forward_raycasts[0].is_colliding():
		distance += forward_raycasts[0].get_collision_point() - forward_raycasts[0].global_position
	if forward_raycasts[1].is_colliding():
		distance += forward_raycasts[1].get_collision_point() - forward_raycasts[1].global_position
	return distance

func force_update() -> void:
	for raycast in forward_raycasts + forward_climb_raycasts:
		raycast.force_raycast_update()

func get_average_wall_normal() -> Vector3:
	var sum := Vector3.ZERO
	if forward_raycasts[0].is_colliding():
		sum += forward_raycasts[0].get_collision_normal()
	if forward_raycasts[1].is_colliding():
		sum += forward_raycasts[1].get_collision_normal()
	
	return sum.normalized()
