extends Node3D

class_name LevelStart

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var is_level_preview = false

var collectibles : Dictionary

var cinematic_cameras

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player/StateMachine.level_loaded = true

func ensure_collectable_exists(name):
	if not Global.WORLD_COLLECTIBLES.has(name):
		Global.WORLD_COLLECTIBLES[name] = 0