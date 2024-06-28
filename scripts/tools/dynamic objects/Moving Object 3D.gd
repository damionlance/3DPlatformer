class_name MovingObject3D
extends DynamicPlatform3D

## Moving Object that interacts with RigidBodies and CharacterBodies
## Enable Editable Children to set path and edit PathFollow3D characteristics

## Used to set how quickly your platform rotates independently of the PathFollow3D node. Set in revolutions per second.
@export var rotation_speed := 0.0
## Useful for moving platforms that require a trigger to start moving. Disable this to stop the moving platform from moving at the start of the level.
@export var moving := true
## How many moving objects to follow the same path
@export var number_of_objects := 1
## Reduce this to start the platforms closer together
@export var starting_distance_scale := 1.0
## Increase this to start the platforms further along their path
@export var starting_ratio := 0.0

@export_category("Path Movement Details")
## Time to complete path in seconds. Used to compute speed of platform. Leave at 0.0 to compute based on speed.
@export var travel_time := 20.0
## Speed of travel.
@export var speed_of_platform := 0.0
## Use to make platforms move backwards at the end of their path or only move forward.
## Platforms on disconnected loops will teleport to the beginning if loop is false.
@export var loop := true
## Set the easing type of the moving object. Leave empty to have no easing.
@export var easing_type : Tween.EaseType
## Set the transition type of the moving object. Leave empty to have no transition.
@export var transition_type : Tween.TransitionType
## Set the delay before looping
@export var loop_delay : float = 0.0


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
	
	if speed_of_platform != 0 and travel_time == 0:
		travel_time = path_length / speed_of_platform
	
	for i in number_of_objects:
		var new_path = path_follow.duplicate()
		new_path.name = "PathFollow3D" + str(i + 1)
		$Path3D.add_child(new_path)
		path_follow_agents.append(new_path)
		path_follow_agents_loop.append(false)
		
		add_another_path_follow(new_path, i)
		
		_create_path_tween(new_path)
	pause_platform(not moving)
	path_follow.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for path in path_follow_agents:
		path.get_child(0).rotate(Vector3.UP, (2 * PI) * rotation_speed * delta)

func pause_platform(pause : bool) -> void:
	for platform in path_follow_agents:
		if pause:
			platform.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			platform.process_mode = Node.PROCESS_MODE_INHERIT

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

func _create_path_tween(object_to_tween : PathFollow3D) -> void:
	var tween = create_tween()
	tween.bind_node(object_to_tween)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_BOUND)
	if object_to_tween.progress_ratio != 1.0:
		tween.tween_property(object_to_tween, "progress_ratio", 1.0, travel_time * (1.0 - object_to_tween.progress_ratio)).set_ease(easing_type).set_trans(transition_type).set_delay(loop_delay)
	if loop:
		tween.tween_property(object_to_tween, "progress_ratio", 0.0, travel_time).set_ease(easing_type).set_trans(transition_type).set_delay(loop_delay)
	else:
		object_to_tween.progress_ratio = 0.0
	
	tween.tween_callback(_create_path_tween.bind(object_to_tween))

func linear_movement(delta : float) -> void:
	for path_follow in path_follow_agents:
		var new_ratio = path_follow.progress_ratio
		new_ratio += (speed_of_platform / path_length) * delta
		if new_ratio > 1:
			new_ratio -= 1.0
		path_follow.progress_ratio = new_ratio

func add_another_path_follow(path_follow : PathFollow3D, index : int) -> void:
	var new_ratio = ((1.0/number_of_objects)) * (index)
	if new_ratio > 1.0:
		new_ratio -= int(new_ratio)
	path_follow.progress_ratio = new_ratio
