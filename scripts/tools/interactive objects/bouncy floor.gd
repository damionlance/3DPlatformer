extends Node

var bodies : Array[CharacterBody3D] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_child(0).collision_mask = 2
	get_child(0).connect("body_entered", detect_body)

func detect_body(body : Node) -> void:
	if "state_chart" in body:
		if body.state_chart.get_expression_property("groundpound"):
			body.current_jump = 8
			body.state_chart.send_event("Jump")
		elif not body.state_chart.get_expression_property("crouching"):
			body.current_jump = 2
			body.state_chart.send_event("Jump")
