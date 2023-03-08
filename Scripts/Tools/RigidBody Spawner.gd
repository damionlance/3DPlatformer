@tool
extends Node3D

@export var spawn_velocity : Vector3 = Vector3(1,0,0) : 
	set(new_velocity) :
		spawn_velocity = new_velocity

@export var time_between_launches := 1
@export var spawned_object_lifetime := 1.0
@export var enabled := false

@onready var obj_template := $"object_to_launch"

var timer := Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = time_between_launches
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
			new_child.linear_velocity = spawn_velocity
			new_child.freeze = false
			new_child.visible = true
			new_child.collision_layer = 1
			new_child.set_script(load("res://Scripts/Tools/temporary_object.gd"))
			new_child.how_much = spawned_object_lifetime
			new_child._ready()
			add_child(new_child)
	pass

func _on_velocity_trigger_velocity_trigger_fired(_body):
	enabled = true
