extends Node3D

@export var open_zone_checkpoint : bool = false
var _respawn_zone : RespawnZone

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Respawn Zone Detector".connect("area_entered", add_to_linear_respawn_group)
	$"Player Detector".connect("body_entered", activate)

func add_to_linear_respawn_group(respawn_zone : RespawnZone) -> void:
	_respawn_zone = respawn_zone
	remove_from_group("checkpoint")

func activate(body : Node3D) -> void:
	if not open_zone_checkpoint:
		_respawn_zone.active_checkpoint = self
	else:
		add_to_group("checkpoint")
