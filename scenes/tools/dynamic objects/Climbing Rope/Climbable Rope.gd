@tool
extends Node3D

## Rope attaches relevant CharacterBody3Ds to a hook point that then overtakes controls from the player
@export var height : float = 0.0 :
	set(value):
		height = value
		update_length()

@export var climbing_speed := 3.0
@export var player_height := 2.0

@onready var mesh_instance := $"%MeshInstance3D"
@onready var attach_point := $"Attach Point"

signal attach

var player : CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area3D.connect("body_entered", attach_player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player != null:
		attach_point.position.y += Input.get_axis("Backward", "Forward") * climbing_speed * delta
		if attach_point.position.y > 0:
			attach_point.position.y = 0
		if attach_point.position.y < -height:
			attach_point.position.y = -height
		player.global_position = attach_point.global_position
		if Input.is_action_just_pressed("Jump"):
			release_player()

func attach_player(body : CharacterBody3D) -> void:
	player = body
	attach_point.global_position.y = player.global_position.y
	connect("attach", player.attach_to_object)
	emit_signal("attach", "Climbable Rope")
	pass

func release_player() -> void:
	player = null

func update_length() -> void:
	if Engine.is_editor_hint():
		mesh_instance.mesh.height = height
		mesh_instance.position.y = -height / 2.0
	else:
		await ready
		mesh_instance.mesh.height = height
		mesh_instance.position.y = -height / 2.0
		$"Area3D/CollisionShape3D".shape.size.y = height
		$"Area3D/CollisionShape3D".position.y = -height/2.0
