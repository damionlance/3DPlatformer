extends Node3D

class_name LevelStart

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var is_level_preview = false

var collectibles : Dictionary

var cinematic_cameras

@onready var audio_randomizer := $"Audio Players/Ambient randomizer"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Player/StateMachine.level_loaded = true
	pass # Replace with function body.
  
