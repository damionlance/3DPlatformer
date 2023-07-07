extends Node3D

var properties = ["holdable", "heavy"]
var velocity = Vector3.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	for property in properties:
		add_to_group(property)

func _process(delta):
	$"Skull-rigid".global_position = global_position

func set_collision_layer(layer):
	$"Skull-rigid".set_collision_layer(layer)

func get_collision_layer() -> int:
	return $"Skull-rigid".get_collision_layer()

