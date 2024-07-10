extends Node

@export var speed_change := 0.5

var bodies : Array[CharacterBody3D] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_child(0).collision_layer = 0
	get_child(0).collision_mask = 2
	get_child(0).connect("body_entered", detect_body)
	get_child(0).connect("body_exited", drop_body)

func detect_body(body : Node) -> void:
	if "speed_coefficient" in body:
		body.speed_coefficient = speed_change

func drop_body(body : Node) -> void:
	if "speed_coefficient" in body:
		body.speed_coefficient = 1.0
