extends DynamicPlatform3D
class_name MovingPlatform3D

## Moving platform that interacts with RigidBodies and CharacterBodies
## Enable Editable Children to set path and edit PathFollow3D characteristics

## Time to complete path in seconds.
@export var travel_time := 20.0
## Used to set how quickly your platform rotates independently of the PathFollow3D node. Set in revolutions per second.
@export var rotation_speed := 0.0
## Sets whether the moving platform starts over at beginning at the end of the path.
@export var loop := Animation.LOOP_PINGPONG
## Useful for moving platforms that require a trigger to start moving. Disable this to stop the moving platform from moving at the start of the level.
@export var autoplay := true

@export_category("Layered Dynamic Platforms")
@export var dynamic_platforms : Array[DynamicPlatform3D] = []

@export_category("Triggers")
## Set whether or not a signal is used to enable/disable a moving platform.
@export var trigger_object : Node
## Enable to reset a moving platform to the beginning of its path on signal. Disable to pause/resume movement on signal.
@export var reset_on_trigger := false

@onready var path_follow := $"Path3D/PathFollow3D"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	animation_player.speed_scale /= travel_time
	animation_player.get_animation("Path Follow").loop_mode = loop
	if autoplay:
		animation_player.autoplay = "Path Follow"
	
	if trigger_object != null:
		trigger_object.connect("activate", activate_platform)
		trigger_object.connect("pause", pause_platform)
	
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
	
	if rotation_speed != 0:
		add_to_group("rotating platform")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for child in path_follow.get_children():
		child.rotate(Vector3.UP, (2 * PI) * rotation_speed * delta)

func pause_platform(pause : bool) -> void:
	if pause:
		animation_player.pause()
	else:
		animation_player.play()

func activate_platform(activate : bool) -> void:
	if activate:
		animation_player.play("Path Follow")
	else:
		animation_player.stop(not reset_on_trigger)
