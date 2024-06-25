extends Node3D

@onready var forward_raycasts = [$"Left Forward", $"Right Forward"]
@onready var downward_raycasts = [$"Left Downward", $"Right Downward"]

@onready var state_chart := $%StateChart

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	#Check if raycasts are both colliding
	var colliding := true
	for raycast in forward_raycasts:
		if not raycast.is_colliding():
			colliding = false
			break
	#Check if raycasts normals are within margin of error
	if colliding:
		if forward_raycasts[0].get_collision_normal() == forward_raycasts[1].get_collision_normal():
			state_chart.send_event("Wall Slide")
		pass
