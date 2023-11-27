extends Node3D

var vertical_raycast_positions = [Vector3(-.175,0,-.175), Vector3(0,0,-.25), Vector3(.175,0,-.175),
						 Vector3(-.25,0,0), Vector3(0,0,0), Vector3(.25,0,0),
						 Vector3(-.175,0,.175), Vector3(0,0,.25), Vector3(.175,0,.175)]

var horizontal_raycast_positions = [Vector3(-.353, .707, -.353),Vector3(0, 1, 0),Vector3(.353, .707, .353),
									Vector3(-.707, 0, -.707),Vector3(0, 0, 0),Vector3(.707, 0, .707),
									Vector3(-.353, -.707, -.353),Vector3(0, -1, 0),Vector3(.353, -.707, .353)]

var horizontal_distances_defaults = [Vector3(0,0,100), Vector3(-100,0,0), Vector3(0,0,-100),Vector3(100,0,0) ]

var vertical_raycasts := []
var horizontal_raycasts := []

var vertical_normals := []
var vertical_distances := []
var is_on_floor := false
var is_on_ceiling := false

var horizontal_normals := []
var horizontal_distances := []
var is_on_wall := false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in 4:
		horizontal_raycasts.append([])
		horizontal_normals.append(Vector3.ZERO)
		horizontal_distances.append(horizontal_distances_defaults[i])
	for i in 2:
		vertical_raycasts.append([])
		vertical_normals.append(Vector3.ZERO)
		vertical_distances.append(0.0)
	
	for j in 2:
		for i in 9:
			var raycast = RayCast3D.new()
			var ray_name = "Floor Raycast" if j == 0 else "Ceiling Raycast"
			ray_name += str(i)
			raycast.position = vertical_raycast_positions[i]
			raycast.target_position = Vector3(0, 25 * (-1 if j == 0 else 1), 0)
			vertical_raycasts[j].append(raycast)
			raycast.name = ray_name
			add_child(raycast)
	for j in 4:
		for i in 9:
			var raycast = RayCast3D.new()
			var ray_name = "Wall Raycast" + str(i+(4*j))
			raycast.target_position = Vector3(0, 0, 25).rotated(Vector3.UP, (PI/2)*j)
			var ray = horizontal_raycast_positions[i]
			ray = Vector3(ray.x if j%2==0 else 0, ray.y, ray.x if j%2!=0 else 0)
			raycast.position = ray
			horizontal_raycasts[j].append(raycast)
			raycast.name = ray_name
			add_child(raycast)
			pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for i in 2:
		vertical_normals[i] = Vector3.ZERO
		vertical_distances[i] = 100.0 * (-1 if i == 0 else 1)
		for raycast in vertical_raycasts[i]:
			if not raycast.is_colliding(): continue
			#calculate average normal 
			vertical_normals[0] += raycast.get_collision_normal()
			
			#calculate closest floor collision
			var test_distance = raycast.get_collision_point() - raycast.global_position
			if abs(test_distance.y) < abs(vertical_distances[i]):
				vertical_distances[i] = test_distance.y
		vertical_normals[i] = vertical_normals[i].normalized()
	for i in 4:
		horizontal_distances[i] = horizontal_distances_defaults[i]
		var j = 0
		for raycast in horizontal_raycasts[i]:
			if not raycast.is_colliding(): continue
			#calculate average normal 
			horizontal_normals[i] += raycast.get_collision_normal()
			
			#calculate closest floor collision
			var test_distance = raycast.get_collision_point() - raycast.global_position
			if test_distance.length() > horizontal_distances[i].length() or j == 0:
				horizontal_distances[i] = test_distance
				horizontal_distances[i].y = 0.0
			j += 1
		horizontal_normals[i] = horizontal_normals[i].normalized()
	
	is_on_floor = true if abs(vertical_distances[0]) < 1.1 else false
