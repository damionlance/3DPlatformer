extends Node

@export var max_health := 2

@onready var current_health := max_health
signal killed(hazard)

func decrement_health(hazard : Node = null) -> void:
	current_health -= 1
	if current_health == 0:
		emit_signal("killed", self)
		current_health = max_health

func increment_health() -> void:
	if current_health == max_health:
		return
	current_health += 1
