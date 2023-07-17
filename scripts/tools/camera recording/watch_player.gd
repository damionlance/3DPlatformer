extends Camera3D

@onready var _player = $"../../../Player"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _player != null:
		look_at(_player.global_position)
