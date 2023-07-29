extends Node


func _ready():
	get_child(0).add_to_group("hazard")
