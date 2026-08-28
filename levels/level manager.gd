class_name StageManager extends Node3D
@export var player : Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.stage_manager = self
