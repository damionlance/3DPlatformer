extends Node3D

class_name LevelStart

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var collectibles : Dictionary
@onready var audio_randomizer := $"Audio Players/Ambient randomizer"
# Called when the node enters the scene tree for the first time.
func _ready():
	$Player/StateMachine.level_loaded = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if $Player.global_position.y < -10:
		get_tree().reload_current_scene()
#if randi()%10000 < 2:
		#audio_randomizer.play()
	pass
