extends Node3D

class_name LevelStart

signal level_loaded

var is_level_preview = false

var collectibles : Dictionary

var cinematic_cameras

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player/StateMachine.level_loaded = true
	emit_signal("level_loaded")

func ensure_collectable_exists(collectable_name):
	if not Global.WORLD_COLLECTIBLES.has(collectable_name):
		Global.WORLD_COLLECTIBLES[collectable_name] = 0
