extends Node3D

var vertical_raycast_positions = [Vector3(-.175,0,-.175), Vector3(0,0,-.25), Vector3(.175,0,-.175),
						 Vector3(-.25,0,0), Vector3(0,0,0), Vector3(.25,0,0),
						 Vector3(-.175,0,.175), Vector3(0,0,.25), Vector3(.175,0,.175)]

var horizontal_raycast_positions = [Vector3.ZERO,Vector3.UP]

var vertical_extents := 1.0
var horizontal_extents := .75

var average_floor_normal := Vector3.ZERO
var average_floor_distance := -100.0
var closest_floor_distance := -100.0
var center_floor_distance := 0.0
var closest_wall_collision := Vector3.ZERO


@export var maximum_step_height := 0.251

@export var maximum_floor_angle := 0.08715574274
@export var maximum_ceiling_angle := -0.08715574274

@onready var player = get_parent()

var raycasts := []

@export var horizontal_raycast_number := 12

var is_on_floor := false
var is_on_ceiling := false

var normals := []
var wall_distance := Vector3.FORWARD * 10000
var is_on_wall := false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for j in 2:
		for i in 9:
			var raycast = RayCast3D.new()
			var ray_name = "Default"
			if j == 0:
				if i == 7:
					ray_name = "Front Raycast"
				if i == 4:
					ray_name = "Center Raycast"
			else:
				ray_name = "Floor Raycast" if j == 0 else "Ceiling Raycast"
				ray_name += str(i)
			raycast.position = vertical_raycast_positions[i]
			raycast.target_position = Vector3(0, 25 * (-1 if j == 0 else 1), 0)
			raycasts.append(raycast)
			raycast.name = ray_name
			add_child(raycast)
	for j in 2:
		for i in horizontal_raycast_number:
			var raycast = RayCast3D.new()
			var ray_name = "Wall Raycast" + str(i+(12*j))
			raycast.target_position = Vector3(0, 0, 25).rotated(Vector3.UP, (TAU/horizontal_raycast_number)*i)
			raycast.position = horizontal_raycast_positions[j] - raycast.target_position.normalized() * .25
			raycast.position.y -= maximum_step_height * 2 - .1
			raycasts.append(raycast)
			raycast.name = ray_name
			add_child(raycast)
			pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	calculate_collisions()

func calculate_collisions():
	average_floor_normal = Vector3.ZERO
	is_on_floor = false
	is_on_ceiling = false
	is_on_wall = false
	normals = []
	average_floor_distance = 0.0
	center_floor_distance = -100.0
	closest_wall_collision = Vector3.UP * 1000
	var closest_floor_distance = -100.0
	var number_of_floor_collisions := 0
	
	for raycast in raycasts:
		if not raycast.is_colliding():continue
		
		# Vertical raycasts
		if raycast.target_position.y != 0:
			var test_distance = raycast.get_collision_point().y - raycast.global_position.y
			# hitting the floor
			if test_distance < 0:
				test_distance += vertical_extents
				number_of_floor_collisions += 1
				average_floor_distance += test_distance
				if test_distance > closest_floor_distance:
					closest_floor_distance = snappedf(test_distance, 0.01)
				if raycast.name == "Center Raycast":
					center_floor_distance = snappedf(test_distance, 0.01)
				if abs(test_distance) < player.velocity.y or test_distance > 0:
					if raycast.get_collision_normal().y > maximum_floor_angle:
						average_floor_normal += raycast.get_collision_normal()
		# horizontal raycasts
		else:
			var test_distance = raycast.get_collision_point() - raycast.global_position
			test_distance -= test_distance.normalized() * .25
			if closest_wall_collision == Vector3.UP * 1000:
				closest_wall_collision = test_distance
			elif closest_wall_collision.length() > test_distance.length():
				closest_wall_collision = test_distance
			if test_distance.length() - horizontal_extents < player.horizontal_velocity.length():
				normals.append(raycast.get_collision_normal())
				if test_distance.y > maximum_ceiling_angle and test_distance.y < maximum_floor_angle:
					is_on_wall = true
	if average_floor_normal != Vector3.ZERO:
		average_floor_normal = average_floor_normal.normalized()
		normals.append(average_floor_normal)
	
	if number_of_floor_collisions != 0:
		average_floor_distance /= number_of_floor_collisions
		average_floor_distance = snappedf(average_floor_distance, 0.01)
		if closest_floor_distance >= -0.1:
			is_on_floor = true
	if center_floor_distance == 0:
		center_floor_distance = average_floor_distance
