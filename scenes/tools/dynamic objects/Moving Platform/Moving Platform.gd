class_name MovingPlatform3D
extends DynamicPlatform3D

## Moving platform that interacts with RigidBodies and CharacterBodies
## Enable Editable Children to set path and edit PathFollow3D characteristics

## Time to complete path in seconds. Used to compute speed of platform.
@export var travel_time := 20.0
## Speed of travel. Leave at 0.0 to automatically compute based on time.
@export var speed_of_platform := 0.0
## Used to set how quickly your platform rotates independently of the PathFollow3D node. Set in revolutions per second.
@export var rotation_speed := 0.0
## Use to make platforms move backwards at the end of their path or only move forward.
## Platforms on disconnected loops will teleport to the beginning if loop is false.
@export var loop := true
## Useful for moving platforms that require a trigger to start moving. Disable this to stop the moving platform from moving at the start of the level.
@export var moving := true
## How many moving platforms to follow the same path
@export var number_of_platforms := 1
## Reduce this to start the platforms closer together
@export var starting_distance_scale := 1.0
## Increase this to start the platforms further along their path
@export var starting_ratio := 0.0

@export_category("Layered Dynamic Platforms")
@export var dynamic_platforms : Array[DynamicPlatform3D] = []

@export_category("Triggers")
## Set whether or not a signal is used to enable/disable a moving platform.
@export var trigger_object : Node
## Enable to reset a moving platform to the beginning of its path on signal. Disable to pause/resume movement on signal.
@export var reset_on_trigger := false

@export var object_to_trigger : Node

@onready var path_follow := $"PathFollow3D"
@onready var path_length : float = $"Path3D".curve.get_baked_length()

var path_follow_agents : Array[PathFollow3D] = []
var path_follow_agents_loop : Array[bool] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#if trigger_object != null:
	#	trigger_object.connect("activate", activate_platform)
	#	trigger_object.connect("pause", pause_platform)
	
	if dynamic_platforms.size() != 0:
		path_follow.get_child(0).queue_free()
		for dynamic_platform in dynamic_platforms:
			dynamic_platform.reparent.call_deferred(path_follow)
	else:
		if mesh == null:
			mesh = MeshInstance3D.new()
			var mesh_instance := BoxMesh.new()
			mesh_instance.size = Vector3(size.x, 0.5, size.y)
			mesh_instance.material = StandardMaterial3D.new()
			mesh_instance.material.albedo_color = mesh_color
			mesh.mesh = mesh_instance
			platform.add_child(mesh)
			generate_collision_data()
		else:
			mesh.reparent(platform)
			generate_collision_data()
	
	for i in number_of_platforms:
		var new_path = path_follow.duplicate()
		new_path.name = "PathFollow3D" + str(i + 1)
		$Path3D.add_child(new_path)
		path_follow_agents.append(new_path)
		path_follow_agents_loop.append(false)
		add_another_path_follow(new_path, i + 1)
	path_follow.queue_free()
	
	if speed_of_platform == 0.0:
		speed_of_platform = path_length / travel_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if loop:
		loop_movement(delta)
	else:
		linear_movement(delta)
	for path in path_follow_agents:
		path.get_child(0).rotate(Vector3.UP, (2 * PI) * rotation_speed * delta)

func pause_platform(pause : bool) -> void:
	moving = pause

func loop_movement(delta: float) -> void:
	var i = 0
	for path_follow in path_follow_agents:
		var negate := 1
		if path_follow_agents_loop[i]:
			negate = -1
		var new_ratio = path_follow.progress_ratio
		if new_ratio + (negate * (speed_of_platform / path_length) * delta) > 1 or new_ratio + (negate * (speed_of_platform / path_length) * delta) < 0:
			path_follow_agents_loop[i] = not path_follow_agents_loop[i]
			negate *= -1
		new_ratio +=(negate * (speed_of_platform / path_length) * delta)
		path_follow.progress_ratio = new_ratio
		i += 1
func linear_movement(delta : float) -> void:
	for path_follow in path_follow_agents:
		var new_ratio = path_follow.progress_ratio
		new_ratio += (speed_of_platform / path_length) * delta
		if new_ratio > 1:
			new_ratio -= 1.0
		path_follow.progress_ratio = new_ratio

func add_another_path_follow(path_follow : PathFollow3D, index : int) -> void:
	
	path_follow.progress_ratio = ((1.0/number_of_platforms)) * (index)
