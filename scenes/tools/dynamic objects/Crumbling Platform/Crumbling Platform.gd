class_name CrumblingPlatform
extends DynamicPlatform3D

## Crumbling platform that interacts with CharacterBody3D
## Collapses after set time

## Time a platform can be stood on before crumbling
@export var time_to_crumble : float = 5.0
## Time a platform takes to return after crumbling
@export var time_to_return : float = 1.0
## Defines whether or not the platform rotates
@export var rotation_speed : float = 0.0

@export_category("Crumble Properties")
## Disable this flag to reset a platform the moment the player leaves it
@export var continue_collapse_after_player_leaves := true

@onready var timer := $Timer
@onready var trigger := $Trigger
@onready var animation_player : AnimationPlayer = $%AnimationPlayer

var player : CharacterBody3D
var _reset_crumble := false

# Called when the node enters the scene tree for the first time.
func _ready():
	if mesh == null:
		mesh = MeshInstance3D.new()
		var mesh_instance := BoxMesh.new()
		mesh_instance.size = Vector3(size.x, 0.5, size.y)
		mesh_instance.material = StandardMaterial3D.new()
		mesh_instance.material.albedo_color = mesh_color
		mesh.mesh = mesh_instance
		object.add_child(mesh)
		generate_collision_data()
	else:
		mesh.reparent(object)
		generate_collision_data()
	for child in object.get_children():
		if child is CollisionShape3D:
			trigger.add_child(child.duplicate())
			trigger.get_child(0).position.y += .1
	
	trigger.connect("body_entered", detect_player_on_ground)
	trigger.connect("body_exited", detect_player_left_ground)
	
	timer.connect("timeout", timer_timeout)

func timer_timeout() -> void:
	if object.collision_layer == 4 and _reset_crumble:
		animation_player.play("RESET")
		object.collision_layer = 0
		object.visible = false
		_reset_crumble = false
		timer.start(time_to_return)
	else:
		object.collision_layer = 4
		object.visible = true
		if player != null:
			detect_player_on_ground(player)
	pass

func detect_player_left_ground(body : Node3D) -> void:
	if not continue_collapse_after_player_leaves:
		timer.stop()
		animation_player.play("RESET")
	player = null

func detect_player_on_ground(body : Node3D) -> void:
	if body is CharacterBody3D:
		player = body
		timer.start(time_to_crumble)
		_reset_crumble = true
		if animation_player.has_animation("start_collapse"):
			animation_player.play("start_collapse")
