@tool
extends Node3D

@export var spawn_velocity : Vector3 = Vector3(1,0,0) : 
	set(new_velocity) :
		spawn_velocity = new_velocity

@export var time_between_launches := 1
@export var spawned_object_lifetime := 1.0
@export var enabled := false
@export var should_disappear_on_touch := false
@export var launch_varience: float = 0.2


@onready var obj_template := $"object_to_launch"

var timer := Timer.new()
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = time_between_launches*rng.randf_range(1-launch_varience, 1+launch_varience)
	timer.one_shot = true
	timer.autostart = true
	obj_template.visible = false
	add_child(timer)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Engine.is_editor_hint():
		$"direction visualizer".target_position = spawn_velocity.normalized()
	elif enabled:
		if timer.time_left == 0:
			timer.start(time_between_launches)
			var new_child = $"object_to_launch".duplicate()
			var temp_velo = Vector3(spawn_velocity.x*rng.randf_range(1-launch_varience, 1+launch_varience), spawn_velocity.y*rng.randf_range(1-launch_varience, 1+launch_varience), spawn_velocity.z*rng.randf_range(1-launch_varience, 1+launch_varience))
			new_child.linear_velocity = temp_velo
			new_child.freeze = false
			new_child.visible = true
			new_child.collision_layer = 1
			new_child.set_script(load("res://Scripts/Tools/temporary_object.gd"))
			if should_disappear_on_touch:
				new_child.disappear_on_touch = true
			new_child.how_much = spawned_object_lifetime
			new_child._ready()
			add_child(new_child)
	pass

func get_enabled():
	return enabled
	
func set_enabled(value):
	enabled = value

func _on_velocity_trigger_velocity_trigger_fired(_body):
	enabled = true