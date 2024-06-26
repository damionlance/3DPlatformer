@tool
extends Node3D

## Rope attaches relevant CharacterBody3Ds to a hook point that then overtakes controls from the player
@export var height : float = 0.0 :
	set(value):
		height = value
		update_length()

@export var player_height := 2.0

@onready var mesh_instance := $"%MeshInstance3D"
@onready var attach_point := $"Attach Point"

var player : CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area3D.connect("body_entered", attach_player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not Engine.is_editor_hint():
		player.global_position = attach_point.global_position

func attach_player(body : CharacterBody3D) -> void:
	player = body
	attach_point.global_position.y = player.global_position.y + player_height
	pass

func update_length() -> void:
	await ready
	mesh_instance.mesh.height = height
	mesh_instance.position.y = -height / 2.0
	$"Area3D/CollisionShape3D".shape.size.y = height
	$"Area3D/CollisionShape3D".position.y = -height/2.0
	pass
