extends Node

class_name Collectable

var collected := false

func _ready():
	if Global.WORLD_COLLECTIBLES.has(name):
		collected = Global.WORLD_COLLECTIBLES[name]
	else:
		Global.WORLD_COLLECTIBLES[name] = collected
